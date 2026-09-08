enum AppLang { ru, tr, en }

extension AppLangX on AppLang {
  String get code => switch (this) {
        AppLang.ru => 'ru',
        AppLang.tr => 'tr',
        AppLang.en => 'en',
      };

  String get nativeName => switch (this) {
        AppLang.ru => 'Русский',
        AppLang.tr => 'Türkçe',
        AppLang.en => 'English',
      };
}

AppLang? langFromCode(String? code) {
  switch (code) {
    case 'ru':
      return AppLang.ru;
    case 'tr':
      return AppLang.tr;
    case 'en':
      return AppLang.en;
    default:
      return null;
  }
}

class L10nText {
  final String ru;
  final String tr;
  final String en;

  const L10nText(this.ru, this.tr, this.en);

  String by(AppLang lang) => switch (lang) {
        AppLang.ru => ru,
        AppLang.tr => tr,
        AppLang.en => en,
      };
}

const Map<String, Map<AppLang, String>> kStrings = {
  'app.name': {
    AppLang.ru: 'MİRAS',
    AppLang.tr: 'MİRAS',
    AppLang.en: 'MİRAS',
  },
  'app.tagline': {
    AppLang.ru: 'Культурно-исторический гид по наследию Турции',
    AppLang.tr: 'Türkiye\'nin kültürel ve tarihi miras rehberi',
    AppLang.en: 'A cultural and historical guide to Türkiye\'s heritage',
  },
  'app.cradle': {
    AppLang.ru: 'Колыбель цивилизаций',
    AppLang.tr: 'Uygarlıkların beşiği',
    AppLang.en: 'Cradle of civilisations',
  },
  'hero.sub': {
    AppLang.ru:
        'От древнейшего храма планеты Гёбекли-Тепе до мраморных колоннад Сиде — десять тысяч лет истории, которыми гордится нация.',
    AppLang.tr:
        'Gezegenin en eski tapınağı Göbekli Tepe\'den Side\'in mermer sütunlarına — bir ulusun gururla andığı on bin yıllık tarih.',
    AppLang.en:
        'From the planet\'s oldest temple at Göbekli Tepe to the marble colonnades of Side — ten thousand years of history a nation is proud of.',
  },
  'action.gallery': {
    AppLang.ru: 'Смотреть галерею',
    AppLang.tr: 'Galeriye git',
    AppLang.en: 'Open the gallery',
  },
  'action.sources': {
    AppLang.ru: 'Источники фото',
    AppLang.tr: 'Fotoğraf kaynakları',
    AppLang.en: 'Photo sources',
  },
  'action.details': {
    AppLang.ru: 'Подробнее',
    AppLang.tr: 'Ayrıntılar',
    AppLang.en: 'Details',
  },
  'action.language': {
    AppLang.ru: 'Язык',
    AppLang.tr: 'Dil',
    AppLang.en: 'Language',
  },
  'action.map': {
    AppLang.ru: 'Карта',
    AppLang.tr: 'Harita',
    AppLang.en: 'Map',
  },
  'section.map': {
    AppLang.ru: 'Карта Турции',
    AppLang.tr: 'Türkiye haritası',
    AppLang.en: 'Map of Türkiye',
  },
  'map.hint': {
    AppLang.ru: 'Нажмите на маркер — появится название; ещё раз — откроется раздел. Карта масштабируется щипком',
    AppLang.tr: 'İşaretçiye dokunun — adı görünür; tekrar dokunun — sayfası açılır. Haritayı yakınlaştırın',
    AppLang.en: 'Tap a marker to see its name, tap again to open the page. Pinch to zoom',
  },
  'music.title': {
    AppLang.ru: 'Музыка эпохи',
    AppLang.tr: 'Dönem müziği',
    AppLang.en: 'Music of the era',
  },
  'music.load': {
    AppLang.ru: 'Загрузить MP3',
    AppLang.tr: 'MP3 yükle',
    AppLang.en: 'Load MP3',
  },
  'music.hint': {
    AppLang.ru: 'Выберите MP3 — он сохранится в приложении и будет играть во всех разделах этой эпохи.',
    AppLang.tr: 'Bir MP3 seçin — uygulamada saklanır ve bu dönemin tüm sayfalarında çalar.',
    AppLang.en: 'Pick an MP3 — it is stored in the app and plays on every page of this era.',
  },
  'music.loaded': {
    AppLang.ru: 'Мелодия сохранена',
    AppLang.tr: 'Melodi kaydedildi',
    AppLang.en: 'Melody saved',
  },
  'music.loadFailed': {
    AppLang.ru: 'Не удалось загрузить мелодию',
    AppLang.tr: 'Melodi yüklenemedi',
    AppLang.en: 'Failed to load the melody',
  },
  'music.playing': {
    AppLang.ru: 'Играет',
    AppLang.tr: 'Çalıyor',
    AppLang.en: 'Playing',
  },
  'music.paused': {
    AppLang.ru: 'Пауза',
    AppLang.tr: 'Duraklatıldı',
    AppLang.en: 'Paused',
  },
  'section.pride': {
    AppLang.ru: 'Гордость нации',
    AppLang.tr: 'Ulusal gurur',
    AppLang.en: 'National pride',
  },
  'section.prideSub': {
    AppLang.ru: 'То, что в Турции знает наизусть каждый школьник',
    AppLang.tr: 'Her Türk çocuğunun ezbere bildiği değerler',
    AppLang.en: 'What every schoolchild in Türkiye knows by heart',
  },
  'section.timeline': {
    AppLang.ru: 'Хроника цивилизаций',
    AppLang.tr: 'Uygarlıklar kronolojisi',
    AppLang.en: 'Chronicle of civilisations',
  },
  'section.gallery': {
    AppLang.ru: 'Галерея наследия',
    AppLang.tr: 'Miras galerisi',
    AppLang.en: 'Heritage gallery',
  },
  'section.gallerySub': {
    AppLang.ru: '26 объектов — от неолита до Республики',
    AppLang.tr: '26 varlık — neolitikten Cumhuriyet\'e',
    AppLang.en: '26 landmarks — from the Neolithic to the Republic',
  },
  'search.hint': {
    AppLang.ru: 'Поиск: Сиде, Эфес, İstanbul…',
    AppLang.tr: 'Ara: Side, Efes, İstanbul…',
    AppLang.en: 'Search: Side, Ephesus, İstanbul…',
  },
  'era.all': {
    AppLang.ru: 'Все',
    AppLang.tr: 'Tümü',
    AppLang.en: 'All',
  },
  'badge.unesco': {
    AppLang.ru: 'ЮНЕСКО',
    AppLang.tr: 'UNESCO',
    AppLang.en: 'UNESCO',
  },
  'pride.label': {
    AppLang.ru: 'Гордость Турции',
    AppLang.tr: 'Türkiye\'nin gururu',
    AppLang.en: 'Pride of Türkiye',
  },
  'detail.region': {
    AppLang.ru: 'Регион',
    AppLang.tr: 'Bölge',
    AppLang.en: 'Region',
  },
  'detail.date': {
    AppLang.ru: 'Дата',
    AppLang.tr: 'Tarih',
    AppLang.en: 'Date',
  },
  'detail.era': {
    AppLang.ru: 'Эпоха',
    AppLang.tr: 'Dönem',
    AppLang.en: 'Era',
  },
  'detail.legend': {
    AppLang.ru: 'Легенды и мифы',
    AppLang.tr: 'Efsaneler ve mitler',
    AppLang.en: 'Legends & myths',
  },
  'detail.gettingThere': {
    AppLang.ru: 'Как добраться',
    AppLang.tr: 'Nasıl gidilir',
    AppLang.en: 'Getting there',
  },
  'prices.disclaimer': {
    AppLang.ru: 'Цены ориентировочные — уточняйте перед поездкой.',
    AppLang.tr: 'Fiyatlar yaklaşık — yolculuk öncesi kontrol edin.',
    AppLang.en: 'Prices are approximate — check before you go.',
  },
  'detail.coords': {
    AppLang.ru: 'Координаты',
    AppLang.tr: 'Koordinatlar',
    AppLang.en: 'Coordinates',
  },
  'empty.search': {
    AppLang.ru: 'Ничего не найдено',
    AppLang.tr: 'Sonuç bulunamadı',
    AppLang.en: 'Nothing found',
  },
  'photo.unavailable': {
    AppLang.ru: 'Фото недоступно',
    AppLang.tr: 'Fotoğraf yok',
    AppLang.en: 'Photo unavailable',
  },
  'quote.text': {
    AppLang.ru: '«Как счастливо тому, кто может сказать: я — турк!»',
    AppLang.tr: '«Ne mutlu Türküm diyene!»',
    AppLang.en: '"How happy is the one who can say: I am a Turk!"',
  },
  'quote.author': {
    AppLang.ru: 'Мустафа Кемаль Ататюрк',
    AppLang.tr: 'Mustafa Kemal Atatürk',
    AppLang.en: 'Mustafa Kemal Atatürk',
  },
  'stats.temple': {
    AppLang.ru: 'лет древнейшему храму — Гёбекли-Тепе',
    AppLang.tr: 'yıl — en eski tapınak Göbekli Tepe',
    AppLang.en: 'years — the oldest temple, Göbekli Tepe',
  },
  'stats.unesco': {
    AppLang.ru: 'объектов ЮНЕСКО',
    AppLang.tr: 'UNESCO varlığı',
    AppLang.en: 'UNESCO sites',
  },
  'stats.wonders': {
    AppLang.ru: 'чуда света из семи древних',
    AppLang.tr: 'yedi antik harikadan ikisi',
    AppLang.en: 'of the seven ancient Wonders',
  },
  'stats.republic': {
    AppLang.ru: 'год Республики — молодость древней земли',
    AppLang.tr: 'Cumhuriyet yılı — kadim toprağın gençliği',
    AppLang.en: 'the Republic — an ancient land\'s youth',
  },
  'sources.title': {
    AppLang.ru: 'Источники фото',
    AppLang.tr: 'Fotoğraf kaynakları',
    AppLang.en: 'Photo sources',
  },
  'sources.note': {
    AppLang.ru:
        'Все фотографии — Wikimedia Commons, лицензии Creative Commons / Public Domain. Приложение работает полностью офлайн; ссылки приведены для атрибуции авторов.',
    AppLang.tr:
        'Tüm fotoğraflar Wikimedia Commons\'tan, Creative Commons / Public Domain lisanslıdır. Uygulama tamamen çevrimdışı çalışır; bağlantılar atıf içindir.',
    AppLang.en:
        'All photos are from Wikimedia Commons under Creative Commons / Public Domain licences. The app is fully offline; links are for attribution.',
  },
  'sources.empty': {
    AppLang.ru: 'Манифест пуст',
    AppLang.tr: 'Manifest boş',
    AppLang.en: 'Manifest is empty',
  },
  'footer.photos': {
    AppLang.ru: 'Фото: Wikimedia Commons · CC BY-SA / Public Domain',
    AppLang.tr: 'Fotoğraflar: Wikimedia Commons · CC BY-SA / Public Domain',
    AppLang.en: 'Photos: Wikimedia Commons · CC BY-SA / Public Domain',
  },
};

String t(AppLang lang, String key) => kStrings[key]![lang]!;
