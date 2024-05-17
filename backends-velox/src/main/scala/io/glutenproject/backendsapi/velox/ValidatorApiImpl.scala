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
package io.glutenproject.backendsapi.velox

import io.glutenproject.backendsapi.ValidatorApi
import io.glutenproject.exec.Runtimes
import io.glutenproject.extension.ValidationResult
import io.glutenproject.substrait.plan.PlanNode
import io.glutenproject.validate.NativePlanValidationInfo
import io.glutenproject.vectorized.NativePlanEvaluator

import org.apache.spark.sql.catalyst.expressions.{CreateMap, Explode, Expression, Generator, JsonTuple, Literal, PosExplode}
import org.apache.spark.sql.catalyst.plans.physical.Partitioning
import org.apache.spark.sql.execution.SparkPlan
import org.apache.spark.sql.types.{ArrayType, BinaryType, BooleanType, ByteType, DataType, DateType, DecimalType, DoubleType, FloatType, IntegerType, LongType, MapType, NullType, ShortType, StringType, StructType, TimestampType}

class ValidatorApiImpl extends ValidatorApi {

  override def doExprValidate(substraitExprName: String, expr: Expression): Boolean =
    doExprValidate(Map(), substraitExprName, expr)

  override def doNativeValidateWithFailureReason(plan: PlanNode): NativePlanValidationInfo = {
    val tmpRuntime = Runtimes.tmpInstance()
    try {
      val validator = NativePlanEvaluator.createForValidation(tmpRuntime)
      validator.doNativeValidateWithFailureReason(plan.toProtobuf.toByteArray)
    } finally {
      tmpRuntime.release()
    }
  }

  override def doSparkPlanValidate(plan: SparkPlan): Boolean = true

  private def isPrimitiveType(dataType: DataType): Boolean = {
    dataType match {
      case BooleanType | ByteType | ShortType | IntegerType | LongType | FloatType | DoubleType |
          StringType | BinaryType | _: DecimalType | DateType | TimestampType | NullType =>
        true
      case _ => false
    }
  }

  override def doSchemaValidate(schema: DataType): Option[String] = {
    if (isPrimitiveType(schema)) {
      return None
    }
    schema match {
      case map: MapType =>
        doSchemaValidate(map.keyType).orElse(doSchemaValidate(map.valueType))
      case struct: StructType =>
        struct.fields.foreach {
          f =>
            val reason = doSchemaValidate(f.dataType)
            if (reason.isDefined) {
              return reason
            }
        }
        None
      case array: ArrayType =>
        doSchemaValidate(array.elementType)
      case _ =>
        Some(s"do not support data type: $schema")
    }
  }

  override def doColumnarShuffleExchangeExecValidate(
      outputPartitioning: Partitioning,
      child: SparkPlan): Option[String] = {
    doSchemaValidate(child.schema)
  }

  override def doGeneratorValidate(generator: Generator, outer: Boolean): ValidationResult = {
    if (outer) {
      return ValidationResult.notOk(s"Velox backend does not support outer")
    }
    generator match {
      case generator: JsonTuple =>
        ValidationResult.notOk(s"Velox backend does not support this json_tuple")
      case generator: PosExplode =>
        // TODO(yuan): support posexplode and remove this check
        ValidationResult.notOk(s"Velox backend does not support this posexplode")
      case explode: Explode if (explode.child.isInstanceOf[CreateMap]) =>
        // explode(MAP(col1, col2))
        ValidationResult.notOk(s"Velox backend does not support MAP datatype")
      case explode: Explode if (explode.child.isInstanceOf[Literal]) =>
        // explode(ARRAY(1, 2, 3))
        ValidationResult.notOk(s"Velox backend does not support literal Array datatype")
      case explode: Explode =>
        explode.child.dataType match {
          case _: MapType =>
            ValidationResult.notOk(s"Velox backend does not support MAP datatype")
          case _: ArrayType =>
            ValidationResult.notOk(s"Velox backend does not support Array datatype")
          case _ =>
            ValidationResult.ok
        }
      case _ =>
        ValidationResult.ok
    }
  }
}
