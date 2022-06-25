
import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';

class TranslationData {
  static TranslationsByLocale translations = Translations.byLocale("en");

  Future initTranslations() async {
    translations +=
    await GettextImporter().fromAssetDirectory("assets/locales");
  }
}

extension Localization on String {
  String get i18n => localize(this, TranslationData.translations);
  String plural(value) => localizePlural(value, this, TranslationData.translations);
  String fill(List<Object> params) => localizeFill(this, params);
}