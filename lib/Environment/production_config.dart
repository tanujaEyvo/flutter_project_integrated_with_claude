import 'package:eyvo_v3/Environment/base_configuration.dart';

class ProductionConfiguration implements BaseConfig {
  @override
  // String get apiHost => 'https://api-mobile.ebuyerassist.com/URBN-Mobile';
  String get apiHost => 'https://api-mobile.ebuyerassist.com/Eyvo-Mobile';

  @override
  String get domainHost => '';
}
