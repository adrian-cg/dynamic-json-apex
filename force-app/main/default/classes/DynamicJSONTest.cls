@IsTest
private class DynamicJSONTest {

    //This is incompatible because it doesn't extend DynamicJSON.Parsed
    private class IncompatibleType {
        public String username;
        public Integer postCount;
    }

    private class CompatibleType extends DynamicJSON.Parsed {
        public String username;
        public Integer postCount;
    }

    private static final String SAMPLE_JSON = JSON.serialize(
        new Map<String, Object> {
            'username' => 'testUser123@test.com',
            'postCount' => 5,
            'alias' => 'testUser',
            'contactInfo' => new Map<String, Object> {
                'phoneNumber' => '1234567890',
                'address' => new Map<String, Object> {
                    'street' => 'Test Street 123',
                    'city' => 'City'
                }
            }
        }
    );


    @IsTest
    static void parsesAndExposesKnownFields() {
        CompatibleType example = (CompatibleType)DynamicJSON.deserialize(SAMPLE_JSON, CompatibleType.class);

        System.assertEquals('testUser123@test.com', example.username);
        System.assertEquals(5, example.postCount);
    }

    @IsTest
    static void parsesAndExposesUnknownFields() {
        CompatibleType example = (CompatibleType)DynamicJSON.deserialize(SAMPLE_JSON, CompatibleType.class);

        System.assertEquals('testUser', String.valueOf(example.get('alias')));
    }

    @IsTest
    static void parsesAndExposesNestedUnknownFields() {
        CompatibleType example = (CompatibleType)DynamicJSON.deserialize(SAMPLE_JSON, CompatibleType.class);

        //Should return existing properties
        System.assertEquals('1234567890', String.valueOf(example.get('contactInfo.phoneNumber')));
        System.assertEquals('Test Street 123', String.valueOf(example.get('contactInfo.address.street')));

        //Should return null for invalid properties
        System.assertEquals(null, example.get('alias.invalidProperty'));
        System.assertEquals(null, example.get('invalidProperty.invalidNestedProperty.evenMoreInvalidProperties'));
    }

    @IsTest
    static void throwsWhenGivenIncompatibleType() {
        try {
            DynamicJSON.deserialize(SAMPLE_JSON, IncompatibleType.class);
            System.assert(false, 'An exception should have been thrown');
        } catch (DynamicJSON.DynamicJSONException e) {
            System.assert(true); //Expected exception was thrown
        } catch (Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e);
        }
    }

    @IsTest
    static void throwsWhenGivenNullType() {
        try {
            DynamicJSON.deserialize(SAMPLE_JSON, null);
            System.assert(false, 'An exception should have been thrown');
        } catch (DynamicJSON.DynamicJSONException e) {
            System.assert(true); //Expected exception was thrown
        } catch (Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e);
        }
    }
}
