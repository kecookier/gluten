/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.spark.util

import org.apache.spark.internal.Logging

import org.apache.hadoop.fs.{FileSystem, FileUtil, Path}
import org.apache.hadoop.util.{RunJar, StringUtils}

import java.io._
import java.nio.file.Files

import scala.util.matching.Regex

private[spark] object MeituanUtils extends Logging {

  /**
   * Unpacks an archive file into the specified directory. It expects .jar, .zip, .tar.gz, .tgz and
   * .tar files. This behaves same as Hadoop's archive in distributed cache. This method is
   * basically copied from `org.apache.hadoop.yarn.util.FSDownload.unpack`.
   */
  def unpack(source: File, dest: File): Unit = {
    if (!source.exists()) {
      throw new FileNotFoundException(source.getAbsolutePath)
    }
    val lowerSrc = StringUtils.toLowerCase(source.getName)
    if (lowerSrc.endsWith(".jar")) {
      RunJar.unJar(source, dest, RunJar.MATCH_ANY)
    } else if (lowerSrc.endsWith(".zip")) {
      // After issue HADOOP-18145, unzip could keep file permissions.
      FileUtil.unZip(source, dest)
    } else if (lowerSrc.endsWith(".tar.gz") || lowerSrc.endsWith(".tgz")) {
      FileUtil.unTar(source, dest)
    } else if (lowerSrc.endsWith(".tar")) {
      // TODO(SPARK-38632): should keep file permissions. Java implementation doesn't.
      unTarUsingJava(source, dest)
    } else {
      logWarning(s"Cannot unpack $source, just copying it to $dest.")
      copyRecursive(source, dest)
    }
  }

  /**
   * The method below was copied from `FileUtil.unTar` but uses Java-based implementation to work
   * around a security issue, see also SPARK-38631.
   */
  private def unTarUsingJava(source: File, dest: File): Unit = {
    if (!dest.mkdirs && !dest.isDirectory) {
      throw new IOException(s"Mkdirs failed to create $dest")
    } else {
      try {
        // Should not fail because all Hadoop 2.1+ (from HADOOP-9264)
        // have 'unTarUsingJava'.
        val mth = classOf[FileUtil].getDeclaredMethod(
          "unTarUsingJava",
          classOf[File],
          classOf[File],
          classOf[Boolean])
        mth.setAccessible(true)
        mth.invoke(null, source, dest, java.lang.Boolean.FALSE)
      } catch {
        // Re-throw the original exception.
        case e: java.lang.reflect.InvocationTargetException if e.getCause != null =>
          throw e.getCause
      }
    }
  }

  private def copyRecursive(source: File, dest: File): Unit = {
    if (source.isDirectory) {
      if (!dest.mkdir()) {
        throw new IOException(s"Failed to create directory ${dest.getPath}")
      }
      val subfiles = source.listFiles()
      subfiles.foreach(f => copyRecursive(f, new File(dest, f.getName)))
    } else {
      Files.copy(source.toPath, dest.toPath)
    }
  }
}
