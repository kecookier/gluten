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

class MyTestOperator extends VeloxWholeStageTransformerSuite {

  protected val rootPath: String = getClass.getResource("/").getPath
  override protected val resourcePath: String = "/tpch-data-parquet-velox"
  override protected val fileFormat: String = "parquet"

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

  test("decimal * decimal with allowPrecisionLoss=false") {
    withSQLConf("spark.sql.decimalOperations.allowPrecisionLoss" -> "false") {
      val df = spark.sql("select cast(100 as decimal(38, 10)) * cast(99999 as decimal(38, 10))")
      val wholeStageTransformers = collect(df.queryExecution.executedPlan) {
        case w: WholeStageTransformer => w
      }
      val nativePlanString = wholeStageTransformers.head.nativePlanString()
      logWarning(s"NativePlan: $nativePlanString")
      val expected = df.collect()
      logWarning(s"expected: ${expected.toString}");
    }
  }

  test("decimal * decimal with allowPrecisionLoss=true") {
    withSQLConf("spark.sql.decimalOperations.allowPrecisionLoss" -> "true") {
      val df = spark.sql("select cast(100 as decimal(38, 10)) * cast(99999 as decimal(38, 10))")
      val wholeStageTransformers = collect(df.queryExecution.executedPlan) {
        case w: WholeStageTransformer => w
      }
      val nativePlanString = wholeStageTransformers.head.nativePlanString()
      logWarning(s"NativePlan: $nativePlanString")
      val expected = df.collect()
      logWarning(s"expected: ${expected.toString}")
    }
  }

  test("decimal * decimal*decimal with allowPrecisionLoss=false") {
    withSQLConf("spark.sql.decimalOperations.allowPrecisionLoss" -> "false") {
      val df = spark.sql(
        "select cast(100 as decimal(38, 10)) * cast(99999 as decimal(38, 10)) *" +
          " cast(99999 as decimal(38, 10))")
      val wholeStageTransformers = collect(df.queryExecution.executedPlan) {
        case w: WholeStageTransformer => w
      }
      val nativePlanString = wholeStageTransformers.head.nativePlanString()
      logWarning(s"NativePlan: $nativePlanString")
      val expected = df.collect()
      logWarning(s"expected: ${expected.toString}")
    }
  }

  test("decimal * decimal*decimal with allowPrecisionLoss=true") {
    val df = spark.sql(
      "select cast(100 as decimal(38, 10)) * cast(99999 as decimal(38, 10)) * " +
        "cast(99999 as decimal(38, 10))")
    val wholeStageTransformers = collect(df.queryExecution.executedPlan) {
      case w: WholeStageTransformer => w
    }
    val nativePlanString = wholeStageTransformers.head.nativePlanString()
    logWarning(s"NativePlan: $nativePlanString")
    val expected = df.collect()
    logWarning(s"expected: ${expected.toString}")
  }
}
