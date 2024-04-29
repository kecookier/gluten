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
package org.apache.gluten.execution

import org.apache.spark.SparkConf
import org.apache.spark.sql.{AnalysisException, Row}
import org.apache.spark.sql.execution.{FilterExec, GenerateExec, ProjectExec, RDDScanExec}
import org.apache.spark.sql.execution.window.WindowExec
import org.apache.spark.sql.functions._
import org.apache.spark.sql.internal.SQLConf
import org.apache.spark.sql.types.{DecimalType, StringType, StructField, StructType}

import org.apache.gluten.GlutenConfig
import org.apache.gluten.sql.shims.SparkShimLoader

import java.util.concurrent.TimeUnit

import scala.collection.JavaConverters

class MyTestOperator extends VeloxWholeStageTransformerSuite {

  protected val rootPath: String = getClass.getResource("/").getPath
  override protected val resourcePath: String = "/tpch-data-parquet-velox"
  override protected val fileFormat: String = "parquet"

  import testImplicits._

  override def beforeAll(): Unit = {
    super.beforeAll()
    createTPCHNotNullTables()
  }

  override protected def sparkConf: SparkConf = {
    super.sparkConf
      .set("spark.shuffle.manager", "org.apache.spark.shuffle.sort.ColumnarShuffleManager")
      .set("spark.sql.files.maxPartitionBytes", "1g")
      .set("spark.sql.shuffle.partitions", "1")
      .set("spark.memory.offHeap.size", "2g")
      .set("spark.unsafe.exceptionOnMemoryLeak", "true")
      .set("spark.sql.autoBroadcastJoinThreshold", "-1")
      .set("spark.sql.sources.useV1SourceList", "avro,parquet")
  }

  test("zhaokuo decimal test") {
    val d = 100
    val df = Seq(d).toDF("DecimalCol")
    val result = df
      .select($"DecimalCol".cast(DecimalType(38, 10)))
      .select(col("DecimalCol") * col("DecimalCol"))
    val wholeStageTransformers = collect(df.queryExecution.executedPlan) {
      case w: WholeStageTransformer => w
    }
    val nativePlanString = wholeStageTransformers.head.nativePlanString()
    logWarning(s"NativePlan: $nativePlanString")
  }
}
