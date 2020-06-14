public class DynamicJSON {

    public abstract class Parsed {
        private Map<String, Object> jsonFields;

        public Object get(String key) {
            return safelyReadJSONValue(jsonFields, key);
        }

        protected void setFields(Map<String, Object> pFields) {
            jsonFields = pFields;
        }
    }

    public static Object deserialize(String jsonString, Type targetType) {
        validateTargetType(targetType);

        Parsed parsedJson = (Parsed)JSON.deserialize(jsonString, targetType);
        parsedJson.setFields((Map<String,Object>)JSON.deserializeUntyped(jsonString));
        
        return parsedJson;
    }

    private static Object safelyReadJSONValue(Map<String, Object> jsonData, String identifier) {
        List<String> nestedKeys = identifier.split('\\.');

        if(nestedKeys.size() == 1) {
            return jsonData.get(identifier);
        }

        String topLevelKey = nestedKeys.remove(0);
        Object jsonValue = jsonData.get(topLevelKey);

        if(jsonValue != null && jsonValue instanceof Map<String,Object>) {
            return safelyReadJSONValue((Map<String,Object>)jsonValue, String.join(nestedKeys, '.'));
        } else {
            //If we get here it means we are trying to access a property from a primitive value, array or null.
            return null;
        }         

    }

    private static void validateTargetType(Type targetType) {
        if(targetType == null) {
            throw new DynamicJSONException('Target Type cannot be null');
        } else if (!Parsed.class.isAssignableFrom(targetType)) {
            throw new DynamicJSONException('Target Type must be a subclass of DynamicJSON.Parsed');
        }
    }

    public class DynamicJSONException extends Exception {}
}
