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
package org.apache.spark.token

import org.apache.spark.SparkEnv
import org.apache.spark.internal.Logging

object MeituanTokenUtils extends Logging {

  def getMeituanToken(): String = {
    SparkEnv.get.tokenManager match {
      case manager: ExecutorTokenManager =>
        val tokenStr = manager.latestTokenToUrlString()
        logInfo(s"Gluten get meituan hdfs token size:${tokenStr.length} value:[$tokenStr]")
        tokenStr
      case _: DriverTokenManager =>
        logInfo("Gluten get meituan hdfs token from driver, empty value")
        ""
      case _ =>
        logWarning("Gluten get meituan hdfs token")
        ""
    }
  }
}
