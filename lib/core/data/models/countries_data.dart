import 'package:core/core/data/models/country.dart';
import 'package:core/core/utils/country_codes.dart';
import 'package:core/core/utils/coutry_dialcodes.dart';

final List<Country> countries = [
  for (final entry in countryCodeMap.entries)
    Country(
      name: entry.key,
      code: entry.value,
      dialCode: countryDialCodeMap[entry.key] ?? '+1',
    ),
];
