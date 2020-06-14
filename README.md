# Typed JSON Parsing with Dynamic properties in Apex (working title)

## Background

Inspired by [Robert Sösemann's tweet](https://twitter.com/rsoesemann/status/1270484037551951872) and [StackExchange question](https://salesforce.stackexchange.com/questions/309042/handle-unknown-properties-with-typed-json-deserialize).

The problem at hand is the ability to parse JSON with some known properties but still be able to dynamically access the one's you don't know. It felt like an interesting problem to solve in Apex so I took an (admitedly clunky) [first swing](https://gist.github.com/adrian-cg/1e4d7955d7e220d60b7815eb0b49757b) at it.

There were a few things wrong with this approach. Main two:

1. The amount of boilerplate: having to manually map known properties for deeply nested objects could get very cumbersome.
2. The API ergonomics: The solution in the gist is very different from what Apex developers are used to:

```apex
public class SomeType {
  public String field1;
  public String field2;
}

SomeType wrapper = (SomeType)JSON.deserialize(jsonString, Sometype.class);
```

## Take 2

With those two issues in mind, I tried again. The focus was on API Ergonomics and having as little boilerplate as possible. With this new approach you have:

1. Very little boilerplate: You only need to have your classes extend DynamicJSON.Parsed.
2. The API is pretty much the same as vanilla Apex:

```apex
public class SomeType extends DynamicJSON.Parsed {
  public String field1;
  public String field2;
}

SomeType wrapper = (SomeType)DynamicJSON.deserialize(jsonString, SomeType.class);
```

There even is an easy way to access nested unkown properties:

```apex
/*
{
  "some": {
    "deeplyNested" {
      "property": "success"
  }
}
*/

wrapper.get('some.deeplyNested.property') //success
```

## Examples

Some examples of how this works can be found in the [Apex Test Class](force-app/main/default/classes/DynamicJSONTest.cls).
