${complexType.name}.cpp
/* Autogenerated with kurento-module-creator */

<#list complexType.getChildren() as dependency>
<#if module.remoteClasses?seq_contains(dependency.type.type) ||
  module.complexTypes?seq_contains(dependency.type.type) ||
  module.events?seq_contains(dependency.type.type)>
#include "${dependency.type.name}.hpp"
</#if>
</#list>
#include "${complexType.name}.hpp"
#include <jsonrpc/JsonSerializer.hpp>
#include <KurentoException.hpp>

<#list module.code.implementation["cppNamespace"]?split("::") as namespace>
namespace ${namespace}
{
</#list>
<#if complexType.typeFormat == "ENUM">

${complexType.name}::type ${complexType.name}::getValueFromString (const std::string &value)
{

  <#list complexType.values as value>
  if (value ==  "${value}") {
    return ${value};
  }

  </#list>
  throw KurentoException (MARSHALL_ERROR,
                          "Invalid value for '${complexType.name}'");

}
</#if>

void ${complexType.name}::Serialize (JsonSerializer &s)
{
<#if complexType.typeFormat == "REGISTER">
  <#if complexType.extends??>
  ${complexType.extends.name}::Serialize (s);

  </#if>

  if (s.IsWriter) {
    s.JsonValue["__type__"] = "${complexType.name}";
  <#if module.name == "core" || module.name == "elements" || module.name == "filters">
    s.JsonValue["__module__"] = "kurento";
  <#else>
    s.JsonValue["__module__"] = "${module.name}";
  </#if>

  <#list complexType.properties as property>
    <#if property.optional>
    if (__isSet${property.name?cap_first}) {
      s.SerializeNVP (${property.name});
    }

    <#else>
    s.SerializeNVP (${property.name});

    </#if>
  </#list>
  } else {
  <#list complexType.properties as property>
    <#assign jsonData = getJsonCppTypeData(property.type)>
    <#if property.optional>
    if (s.JsonValue.isMember ("${property.name}") ) {
      if (s.JsonValue["${property.name}"].isConvertibleTo (Json::ValueType::${jsonData.getJsonValueType()}) ) {
        __isSet${property.name?cap_first} = true;
        s.SerializeNVP (${property.name});
      } else {
        throw KurentoException (MARSHALL_ERROR,
                                "'${property.name}' property should be a ${jsonData.getTypeDescription()}");
      }
    <#if property.defaultValue?? >
    } else {
      Json::Reader reader;
      std::string defaultValue = "${escapeString (property.defaultValue)}";
      reader.parse (defaultValue, s.JsonValue["${property.name}"]);
      if (s.JsonValue["${property.name}"].isConvertibleTo (Json::ValueType::${jsonData.getJsonValueType()}) ) {
        __isSet${property.name?cap_first} = true;
        s.SerializeNVP (${property.name});
      } else {
        throw KurentoException (MARSHALL_ERROR,
                               "Default value of '${property.name}' property should be a ${jsonData.getTypeDescription()}");
      }
    </#if>
    }

    <#else>
    if (!s.JsonValue.isMember ("${property.name}") || !s.JsonValue["${property.name}"].isConvertibleTo (Json::ValueType::${jsonData.getJsonValueType()}) ) {
      throw KurentoException (MARSHALL_ERROR,
                              "'${property.name}' property should be a ${jsonData.getTypeDescription()}");
    }

    s.SerializeNVP (${property.name});

    </#if>
  </#list>
  }
<#else>
  if (s.IsWriter) {
    s.JsonValue = getString();
  } else {
    if (s.JsonValue.isConvertibleTo (Json::ValueType::stringValue) ) {
      enumValue = getValueFromString (s.JsonValue.asString() );
    } else {
      throw KurentoException (MARSHALL_ERROR,
                              "'${complexType.name}' type should be a string");
    }
  }
</#if>
}

<#list module.code.implementation["cppNamespace"]?split("::")?reverse as namespace>
} /* ${namespace} */
</#list>

namespace kurento
{

void
Serialize (std::shared_ptr<${module.code.implementation["cppNamespace"]}::${complexType.name}> &object, JsonSerializer &s)
{
  if (!s.IsWriter && !object) {
 <#if complexType.typeFormat == "REGISTER">
    if (!s.JsonValue.isMember ("__type__") || !s.JsonValue["__type__"].isConvertibleTo (Json::ValueType::stringValue) || !s.JsonValue.isMember ("__module__") || !s.JsonValue["__module__"].isConvertibleTo (Json::ValueType::stringValue)) {
      object.reset (new ${module.code.implementation["cppNamespace"]}::${complexType.name}() );
    } else {
      auto ptr = kurento::RegisterParent::createRegister (s.JsonValue["__module__"].asString () + "." + s.JsonValue["__type__"].asString ());

      if (!ptr) {
        throw KurentoException (UNEXPECTED_ERROR,
                                "Type " + s.JsonValue["__type__"].asString () + " does not exist in module " + s.JsonValue["__module__"].asString ());
      }

      object.reset (dynamic_cast <${module.code.implementation["cppNamespace"]}::${complexType.name}*> (ptr));

      if (!object) {
        delete ptr;
        throw KurentoException (UNEXPECTED_ERROR, "Type " + s.JsonValue["__type__"].asString () + " is not compatible");
      }
    }
 <#else>
    object.reset (new ${module.code.implementation["cppNamespace"]}::${complexType.name}() );
 </#if>
  }

  if (object) {
    object->Serialize (s);
  }
}

} /* kurento */