package Library {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import StringFunctions::*;

    attribute <ha> hectare : AreaUnit {
        :>> unitConversion : MeasurementReferences::ConversionByConvention {
            :>> referenceUnit = m^2;
            :>> conversionFactor = 10000;
        }
    }

    attribute def HectareValue :> AreaValue {
        doc
        /* symbol(s): ha
         * name: Hectare
         * measurement unit(s): m^2
         * conversion factor(s): 1 ha = 10,000 m^2
         */
        :>> mRef = hectare;
    }

    attribute def TonneMassValue :> MassValue {
        doc
        /* symbol(s): tonne
         * name: Tonne
         * measurement unit(s): kg
         * conversion factor(s): 1 tonne = 1000 kg
         */
        :>> mRef = tonne;
    }

    attribute def GeoCoordinate {
        doc
        /* symbol(s): lat, lon
         * name: GeoCoordinate
         * measurement unit(s): degrees (°)
         */
        attribute latitude : AngularMeasureValue;
        attribute longitude : AngularMeasureValue;

        assert constraint ValidLatitude {
            latitude >= -90.0 [degree] and latitude <= 90.0 [degree]
        }

        assert constraint ValidLongitude {
            longitude >= -180.0 [degree] and longitude <= 180.0 [degree]
        }
    }

    attribute def UUID :> String;

    abstract calc def IsNumeric {
        doc
        /* Evaluates to true if the string contains only numeric digits */
        in x : String;
        return : Boolean;
    }

    attribute def NumericCode :> String {
        doc
        /* A string that consists of a specific number of numeric digits. */
        attribute lenght : Natural;

        assert constraint ValidCode {
            Length(that) == lenght and IsNumeric(that)
        }
    }

    abstract calc def MatchesRegex {
        doc
        /* Evaluates to true if the string matches the specified regular expression pattern. */
        in x : String;
        in pattern : String;
        return : Boolean;
    }

    attribute def FormattedCode :> String {
        doc
        /* A string that follows a specific format defined by a regular expression. */
        attribute pattern : String;

        assert constraint ValidCode {
            MatchesRegex(that, pattern)
        }
    }
}
