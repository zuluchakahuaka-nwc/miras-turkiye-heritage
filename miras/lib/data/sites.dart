import '../l10n/strings.dart';

enum Era { ancientWorld, antiquity, byzantium, ottoman, republic }

final Map<Era, L10nText> kEraLabels = {
  Era.ancientWorld: const L10nText('Древний мир', 'Kadim dönem', 'Ancient world'),
  Era.antiquity: const L10nText('Античность', 'Antik çağ', 'Antiquity'),
  Era.byzantium: const L10nText('Византия', 'Bizans', 'Byzantium'),
  Era.ottoman: const L10nText('Османы', 'Osmanlı', 'Ottomans'),
  Era.republic: const L10nText('Республика', 'Cumhuriyet', 'Republic'),
};

L10nText eraLabel(Era era) => kEraLabels[era]!;

String formatYear(int year, AppLang lang) {
  if (year < 0) {
    final v = (-year).toString();
    return switch (lang) {
      AppLang.ru => '$v до н. э.',
      AppLang.tr => 'MÖ $v',
      AppLang.en => '$v BC',
    };
  }
  if (year < 1000) {
    return switch (lang) {
      AppLang.ru => '$year г.',
      AppLang.tr => '$year',
      AppLang.en => 'AD $year',
    };
  }
  return '$year';
}

class Site {
  final String id;
  final L10nText name;
  final L10nText region;
  final L10nText date;
  final Era era;
  final int? unesco;
  final bool featured;
  final int sortYear;
  final L10nText desc;
  final L10nText pride;
  final String wikiRu;
  final String wikiEn;

  const Site({
    required this.id,
    required this.name,
    required this.region,
    required this.date,
    required this.era,
    this.unesco,
    this.featured = false,
    required this.sortYear,
    required this.desc,
    required this.pride,
    required this.wikiRu,
    required this.wikiEn,
  });
}

class TimelineEntry {
  final int year;
  final L10nText title;

  const TimelineEntry(this.year, this.title);
}

const List<Site> kSites = [
  Site(
    id: 'gobekli-tepe',
    name: L10nText('Гёбекли-Тепе', 'Göbekli Tepe', 'Göbekli Tepe'),
    region: L10nText('Шанлыурфа', 'Şanlıurfa', 'Şanlıurfa'),
    date: L10nText('ок. 9500 г. до н. э.', 'MÖ y. 9500', 'c. 9500 BC'),
    era: Era.ancientWorld,
    unesco: 2018,
    featured: true,
    sortYear: -9500,
    desc: L10nText(
      'Древнейший монументальный храм планеты — 12 000 лет. Кольца мегалитических колонн весом до 16 тонн с рельефами зверей возвели задолго до появления городов, письменности и колеса.',
      'Gezegenin en eski anıtsal tapınağı — 12.000 yıl. Kentlerin, yazının ve tekerleğin icadından çok önce, hayvan kabartmalarıyla bezeli, 16 tona kadar ağırlıkta taş kolonlardan oluşan halkalar yükseltildi.',
      'The oldest monumental temple on Earth — 12,000 years old. Rings of stone pillars up to 16 tonnes, carved with animal reliefs, were raised long before cities, writing or the wheel existed.',
    ),
    pride: L10nText(
      'Старше Стоунхенджа на 6 тысяч лет, пирамид — на 7: цивилизация началась в Анатолии.',
      'Stonehenge\'den 6 bin, piramitlerden 7 bin yıl daha yaşlı: uygarlık Anadolu\'da başladı.',
      '6,000 years older than Stonehenge and 7,000 older than the pyramids: civilisation began in Anatolia.',
    ),
    wikiRu: 'Гёбекли-Тепе',
    wikiEn: 'Göbekli Tepe',
  ),
  Site(
    id: 'catalhoyuk',
    name: L10nText('Чатал-Хююк', 'Çatalhöyük', 'Çatalhöyük'),
    region: L10nText('Конья', 'Konya', 'Konya'),
    date: L10nText('ок. 7100 г. до н. э.', 'MÖ y. 7100', 'c. 7100 BC'),
    era: Era.ancientWorld,
    unesco: 2012,
    sortYear: -7100,
    desc: L10nText(
      'Один из первых городов человечества: до 8 000 жителей, дома вплотную друг к другу, входы через крыши, настенные фрески и древнейший известный план поселения.',
      'İnsanlığın ilk kentlerinden biri: 8.000\'e kadar sakin, birbirine bitişik evler, çatılardan girişler, duvar resimleri ve bilinen en eski yerleşim planı.',
      'One of humanity\'s first cities: up to 8,000 residents, houses packed wall-to-wall and entered through the roofs, murals, and the earliest known town plan.',
    ),
    pride: L10nText(
      '9 000 лет городу — на четыре тысячи лет старше пирамид Гизы. Колыбель городской жизни.',
      '9.000 yıllık kent — Giza piramitlerinden dört bin yıl daha yaşlı. Kentleşmenin beşiği.',
      'A 9,000-year-old city — four thousand years older than the pyramids of Giza. The cradle of urban life.',
    ),
    wikiRu: 'Чатал-Хююк',
    wikiEn: 'Çatalhöyük',
  ),
  Site(
    id: 'hattusa',
    name: L10nText('Хаттуса', 'Hattuşa', 'Hattusa'),
    region: L10nText('Чорум', 'Çorum', 'Çorum'),
    date: L10nText('ок. 1650 г. до н. э.', 'MÖ y. 1650', 'c. 1650 BC'),
    era: Era.ancientWorld,
    unesco: 1986,
    sortYear: -1650,
    desc: L10nText(
      'Столица Хеттской державы — сверхдержавы бронзового века. Львиные и царские ворота, храм штормового бога и клинописные архивы на тысячах глиняных табличек.',
      'Tunç Çağı\'nın süper gücü Hitit İmparatorluğu\'nun başkenti. Aslanlı Kapı, Kral Kapısı, fırtına tanrısı tapınağı ve binlerce çivi yazılı tabletten oluşan arşivler.',
      'Capital of the Hittite empire — the Bronze Age superpower. The Lion Gate and King\'s Gate, the storm-god temple and cuneiform archives on thousands of clay tablets.',
    ),
    pride: L10nText(
      'Здесь родился первый в истории международный договор — Кадешский, между хеттами и Египтом.',
      'Tarihteki ilk uluslararası antlaşma — Hititler ile Mısır arasındaki Kadeş Antlaşması — burada doğdu.',
      'The world\'s first international treaty — Kadesh, between the Hittites and Egypt — was born here.',
    ),
    wikiRu: 'Хаттуса',
    wikiEn: 'Hattusa',
  ),
  Site(
    id: 'troy',
    name: L10nText('Троя', 'Truva', 'Troy'),
    region: L10nText('Чанаккале', 'Çanakkale', 'Çanakkale'),
    date: L10nText('ок. 3000 г. до н. э.', 'MÖ y. 3000', 'c. 3000 BC'),
    era: Era.ancientWorld,
    unesco: 1998,
    featured: true,
    sortYear: -3000,
    desc: L10nText(
      'Девять городов, построенных друг на друге за 4 000 лет. Город Гомера и Елены: здесь Шлиман нашёл «клад Приама» и доказал, что миф — это история.',
      '4.000 yıl içinde üst üste dokuz kent. Homeros\'un ve Helena\'nın kenti: Schliemann burada "Priamos\'un hazinesini" buldu ve efsanenin tarih olduğunu kanıtladı.',
      'Nine cities built one atop another over 4,000 years. The city of Homer and Helen: here Schliemann found "Priam\'s treasure" and proved the myth was history.',
    ),
    pride: L10nText(
      '«Илиада» начинается на турецкой земле — Троя стоит здесь пять тысяч лет.',
      '"İlyada" Türk topraklarında başlar — Truva burada beş bin yıldır ayakta.',
      'The Iliad begins on Turkish soil — Troy has stood here for five thousand years.',
    ),
    wikiRu: 'Троя',
    wikiEn: 'Troy',
  ),
  Site(
    id: 'ephesus',
    name: L10nText('Эфес', 'Efes', 'Ephesus'),
    region: L10nText('Измир', 'İzmir', 'İzmir'),
    date: L10nText('X в. до н. э.', 'MÖ 10. yüzyıl', '10th c. BC'),
    era: Era.antiquity,
    unesco: 2015,
    featured: true,
    sortYear: -1000,
    desc: L10nText(
      'Жемчужина римской Азии: библиотека Цельса, Большой театр на 24 000 зрителей, улица Куретов. Рядом стоял Артемисион — одно из семи чудес света.',
      'Roma Asyası\'nın incisi: Celsus Kütüphanesi, 24.000 kişilik Büyük Tiyatro, Kuretler Caddesi. Yakınında yedi harikadan biri olan Artemis Tapınağı yükseliyordu.',
      'Jewel of Roman Asia: the Library of Celsus, the Great Theatre seating 24,000, Curetes Street. The Temple of Artemis — one of the Seven Wonders — stood nearby.',
    ),
    pride: L10nText(
      'Город-миллионик античности и чудо света Артемисион: мраморные улицы помнят Клеопатру.',
      'Antik dünyanın milyonluk kenti ve Artemis harikası: mermer sokaklar Kleopatra\'yı hatırlar.',
      'An ancient metropolis of a million and the Wonder of Artemis: its marble streets remember Cleopatra.',
    ),
    wikiRu: 'Эфес',
    wikiEn: 'Ephesus',
  ),
  Site(
    id: 'side',
    name: L10nText('Сиде', 'Side', 'Side'),
    region: L10nText('Анталья', 'Antalya', 'Antalya'),
    date: L10nText('VII в. до н. э.', 'MÖ 7. yüzyıl', '7th c. BC'),
    era: Era.antiquity,
    featured: true,
    sortYear: -700,
    desc: L10nText(
      'Город-музей под открытым небом: храм Аполлона, чьи колонны горят на закате, римский театр, агора и древний водовод — руины среди апельсиновых садов и моря.',
      'Açık hava müzesi kent: gün batımında yanan sütunlarıyla Apollon Tapınağı, Roma tiyatrosu, agora ve antik su kemeri — portakal bahçeleriyle denizin arasına gömülü kalıntılar.',
      'A museum-city in the open air: the Temple of Apollo whose columns blaze at sunset, the Roman theatre, the agora and the ancient aqueduct — ruins set among orange groves and the sea.',
    ),
    pride: L10nText(
      'Пять колонн Аполлона на закате — самая узнаваемая открытка Средиземноморья.',
      'Gün batımındaki beş Apollon sütunu, Akdeniz\'in en tanınan kartpostalı.',
      'The five columns of Apollo at sunset — the Mediterranean\'s most recognisable postcard.',
    ),
    wikiRu: 'Сиде',
    wikiEn: 'Side, Turkey',
  ),
  Site(
    id: 'aspendos',
    name: L10nText('Аспендос', 'Aspendos', 'Aspendos'),
    region: L10nText('Анталья', 'Antalya', 'Antalya'),
    date: L10nText('155 г.', 'MS 155', 'AD 155'),
    era: Era.antiquity,
    sortYear: 155,
    desc: L10nText(
      'Римский театр на 15 000 зрителей — лучше всех сохранившийся в мире. Каждое лето здесь звучат оперные арии международного фестиваля.',
      '15.000 kişilik Roma tiyatrosu — dünyada en iyi korunmuş olanı. Her yaz uluslararası festivalin opera aryaları burada yankılanır.',
      'A Roman theatre for 15,000 — the best preserved on Earth. Every summer, opera arias of the international festival echo here.',
    ),
    pride: L10nText(
      'Акустика, рассчитанная 19 веков назад, работает без единого микрофона.',
      '19 yüzyıl önce hesaplanan akustik, tek bir mikrofonsuz bile çalışıyor.',
      'Acoustics calculated 19 centuries ago still work without a single microphone.',
    ),
    wikiRu: 'Аспендос',
    wikiEn: 'Aspendos',
  ),
  Site(
    id: 'pergamon',
    name: L10nText('Пергам', 'Pergamon', 'Pergamon'),
    region: L10nText('Измир (Бергама)', 'İzmir (Bergama)', 'İzmir (Bergama)'),
    date: L10nText('III в. до н. э.', 'MÖ 3. yüzyıl', '3rd c. BC'),
    era: Era.antiquity,
    unesco: 2014,
    sortYear: -300,
    desc: L10nText(
      'Столица Пергамского царства: самый крутой театр античного мира, алтарь Зевса и Асклепион — древнейший медицинский центр Средиземноморья.',
      'Bergama Krallığı\'nın başkenti: antik dünyanın en dik tiyatrosu, Zeus Sunağı ve Akdeniz\'in en eski sağlık merkezi Asklepion.',
      'Capital of the Pergamene kingdom: the steepest theatre of the ancient world, the Altar of Zeus and the Asclepion — the Mediterranean\'s oldest healing centre.',
    ),
    pride: L10nText(
      'Здесь придумали пергамент — «бумагу», названную в честь города.',
      'Parşömen burada icat edildi ve adını kentten aldı.',
      'Parchment was invented here — and named after the city.',
    ),
    wikiRu: 'Пергам',
    wikiEn: 'Pergamon',
  ),
  Site(
    id: 'nemrut',
    name: L10nText('Немрут-Даг', 'Nemrut Dağı', 'Mount Nemrut'),
    region: L10nText('Адыяман', 'Adıyaman', 'Adıyaman'),
    date: L10nText('62 г. до н. э.', 'MÖ 62', '62 BC'),
    era: Era.antiquity,
    unesco: 1987,
    sortYear: -62,
    desc: L10nText(
      'Святилище царя Коммагены на вершине 2 150 метров: десятиметровые статуи богов и Антиоха I, обращённые к восходу и закату.',
      '2.150 metrelik zirvede Kommagene kralının kutsal alanı: doğuşa ve batışa bakan, on metrelik tanrı ve I. Antiokhos heykelleri.',
      'King Antiochus I of Commagene\'s sanctuary atop a 2,150-metre peak: ten-metre statues of the gods and the king, gazing at sunrise and sunset.',
    ),
    pride: L10nText(
      '«Восьмое чудо света» — колоссы, построенные выше облаков.',
      '"Sekizinci harika" — bulutların üzerine inşa edilmiş dev heykeller.',
      'The "eighth wonder of the world" — colossi built above the clouds.',
    ),
    wikiRu: 'Немрут-Даг',
    wikiEn: 'Mount Nemrut',
  ),
  Site(
    id: 'pamukkale',
    name: L10nText('Иераполь и Памуккале', 'Hierapolis ve Pamukkale', 'Hierapolis & Pamukkale'),
    region: L10nText('Денизли', 'Denizli', 'Denizli'),
    date: L10nText('II в. до н. э.', 'MÖ 2. yüzyıl', '2nd c. BC'),
    era: Era.antiquity,
    unesco: 1988,
    sortYear: -200,
    desc: L10nText(
      'Белоснежные травертиновые террасы горячих источников — «хлопковый замок», а рядом священный Иераполь: некрополь на 1 200 гробниц и бассейн Клеопатры.',
      'Sıcak kaynakların beyaz traverten terasları — "pamuk kalesi"; yanı başında kutsal kent Hierapolis: 1.200 mezarlık nekropol ve Kleopatra Havuzu.',
      'Snow-white travertine terraces of hot springs — the "cotton castle" — beside sacred Hierapolis: a 1,200-tomb necropolis and Cleopatra\'s Pool.',
    ),
    pride: L10nText(
      'Природное чудо и античный город в одном месте: мраморные каскады, которым миллионы лет.',
      'Doğa harikası ve antik kent bir arada: milyonlarca yıllık mermer basamaklar.',
      'A natural wonder and an ancient city in one place: marble cascades millions of years in the making.',
    ),
    wikiRu: 'Памуккале',
    wikiEn: 'Pamukkale',
  ),
  Site(
    id: 'myra',
    name: L10nText('Мира', 'Myra', 'Myra'),
    region: L10nText('Анталья (Демре)', 'Antalya (Demre)', 'Antalya (Demre)'),
    date: L10nText('V в. до н. э.', 'MÖ 5. yüzyıl', '5th c. BC'),
    era: Era.antiquity,
    sortYear: -500,
    desc: L10nText(
      'Ликийские скальные гробницы-фасады, огромный римский театр и церковь Святого Николая — прообраза Санта-Клауса, епископа Миры.',
      'Kayalara oyulmuş Likya mezar cepheleri, dev Roma tiyatrosu ve Noel Baba\'nın öncüsü, Myra piskoposu Aziz Nikola Kilisesi.',
      'Lycian rock-cut tomb façades, a vast Roman theatre and the Church of St Nicholas — the original Santa Claus, bishop of Myra.',
    ),
    pride: L10nText(
      'Санта-Клаус — из Турции: Святой Николай родился и служил в Ликии.',
      'Noel Baba Türkiye\'den: Aziz Nikola Likya\'da doğdu ve görev yaptı.',
      'Santa Claus is from Turkey: St Nicholas was born and served in Lycia.',
    ),
    wikiRu: 'Мира (Ликия)',
    wikiEn: 'Myra',
  ),
  Site(
    id: 'halicarnassus',
    name: L10nText('Галикарнас', 'Halikarnas', 'Halicarnassus'),
    region: L10nText('Бодрум', 'Bodrum', 'Bodrum'),
    date: L10nText('350 г. до н. э.', 'MÖ 350', '350 BC'),
    era: Era.antiquity,
    sortYear: -350,
    desc: L10nText(
      'Мавзолей Мавсола — одно из семи чудес света, около 45 метров высотой, с фризом сражающихся амазонок. Сегодня — гордые руины над бухтой Бодрума.',
      'Yedi harikadan biri Mausoleion — yaklaşık 45 metre yüksekliğinde, savaşan Amazon kabartmalarıyla bezeli. Bugün Bodrum koyunun üzerinde gururlu kalıntılar.',
      'The Mausoleum of Mausolus — one of the Seven Wonders, some 45 m tall, with a frieze of battling Amazons. Today, proud ruins above the Bodrum bay.',
    ),
    pride: L10nText(
      'Второе чудо света на турецкой земле; само слово «мавзолей» родилось здесь.',
      'Türk topraklarında ikinci dünya harikası; "mozole" kelimesi burada doğdu.',
      'A second Wonder of the World on Turkish soil; the very word "mausoleum" was born here.',
    ),
    wikiRu: 'Галикарнасский мавзолей',
    wikiEn: 'Mausoleum at Halicarnassus',
  ),
  Site(
    id: 'cappadocia',
    name: L10nText('Каппадокия', 'Kapadokya', 'Cappadocia'),
    region: L10nText('Невшехир', 'Nevşehir', 'Nevşehir'),
    date: L10nText('IV в.', 'MS 4. yüzyıl', '4th c. AD'),
    era: Era.byzantium,
    unesco: 1985,
    sortYear: 400,
    desc: L10nText(
      'Долина «волшебных дымоходов»: пещерные церкви с фресками и подземные города Деринкую и Каймаклы — до 20 000 жителей, глубиной до 85 метров.',
      '"Peri bacaları" vadisi: freskli kaya kiliseleri ve 20.000 kişiye kadar barındıran, 85 metreye inen Derinkuyu ile Kaymaklı yeraltı kentleri.',
      'The valley of "fairy chimneys": cave churches with frescoes and the underground cities of Derinkuyu and Kaymaklı — up to 20,000 people, 85 m deep.',
    ),
    pride: L10nText(
      'Целые города под землёй: восемь этажей тоннелей — инженерия на полторы тысячи лет вперёд.',
      'Yerin altında koca kentler: sekiz katlı tüneller — 1.500 yıl ileride mühendislik.',
      'Whole cities underground: eight storeys of tunnels — engineering 1,500 years ahead of its time.',
    ),
    wikiRu: 'Каппадокия',
    wikiEn: 'Cappadocia',
  ),
  Site(
    id: 'hagia-sophia',
    name: L10nText('Айя-София', 'Ayasofya', 'Hagia Sophia'),
    region: L10nText('Истанбул', 'İstanbul', 'İstanbul'),
    date: L10nText('537 г.', 'MS 537', 'AD 537'),
    era: Era.byzantium,
    unesco: 1985,
    featured: true,
    sortYear: 537,
    desc: L10nText(
      'Купол диаметром 31 метр, парящий на высоте 55 метров. Тысячу лет — крупнейший храм христианского мира, затем мечеть султанов, сегодня — действующая мечеть.',
      '55 metre yükseklikte süzülen 31 metre çaplı kubbe. Bin yıl Hristiyan dünyasının en büyük tapınağı, sonra sultanların camisi, bugün ibadete açık cami.',
      'A 31-metre dome floating 55 metres high. For a thousand years Christendom\'s greatest church, then the sultans\' mosque, today a working mosque.',
    ),
    pride: L10nText(
      'Юстиниан воскликнул: «Соломон, я превзошёл тебя!» — и тысячу лет равного не построили.',
      'Iustinianos haykırdı: "Süleyman, seni geçtim!" — ve bin yıl boyunca eşi yapılamadı.',
      'Justinian exclaimed: "Solomon, I have surpassed you!" — and for a thousand years nothing matched it.',
    ),
    wikiRu: 'Айя-София',
    wikiEn: 'Hagia Sophia',
  ),
  Site(
    id: 'basilica-cistern',
    name: L10nText('Цистерна Базилика', 'Yerebatan Sarnıcı', 'Basilica Cistern'),
    region: L10nText('Истанбул', 'İstanbul', 'İstanbul'),
    date: L10nText('532 г.', 'MS 532', 'AD 532'),
    era: Era.byzantium,
    sortYear: 532,
    desc: L10nText(
      'Подземный водный дворец на 80 000 м³: 336 колонн, светящиеся в темноте карпы и перевёрнутая голова Медузы Горгоны.',
      '80.000 m³\'lük yeraltı su sarayı: 336 sütun, karanlıkta ışıldayan sazanlar ve baş aşağı duran Medusa başı.',
      'An underground water palace of 80,000 m³: 336 columns, carp glowing in the dark and the upside-down head of Medusa.',
    ),
    pride: L10nText(
      'Водохранилище Юстиниана стоит до сих пор — 15 веков без капитального ремонта.',
      'Iustinianos\'un su deposu hâlâ ayakta — 15 yüzyıl, onarımsız.',
      'Justinian\'s reservoir still stands — 15 centuries without major repair.',
    ),
    wikiRu: 'Цистерна Базилика',
    wikiEn: 'Basilica Cistern',
  ),
  Site(
    id: 'topkapi',
    name: L10nText('Дворец Топкапы', 'Topkapı Sarayı', 'Topkapı Palace'),
    region: L10nText('Истанбул', 'İstanbul', 'İstanbul'),
    date: L10nText('1478 г.', 'MS 1478', 'AD 1478'),
    era: Era.ottoman,
    unesco: 1985,
    sortYear: 1478,
    desc: L10nText(
      'Четыре двора султанов между Босфором и Золотым Рогом: 400 лет — сердце империи трёх континентов. Алмаз «Ложечника» в 86 карат и кинжал Топкапы.',
      'Boğaz ile Haliç arasındaki dört avlulu sultan sarayı: 400 yıl boyunca üç kıtaya hükmeden imparatorluğun kalbi. 86 kırat Kaşıkçı Elması ve Topkapı Hançeri.',
      'The sultans\' four courtyards between the Bosphorus and the Golden Horn: for 400 years the heart of an empire of three continents. The 86-carat Spoonmaker\'s Diamond and the Topkapı Dagger.',
    ),
    pride: L10nText(
      'Из этих стен правили от Венгрии до Алжира — шесть веков подряд.',
      'Bu duvarlardan Macaristan\'dan Cezayir\'e hükmedildi — altı yüzyıl boyunca.',
      'From these walls they ruled from Hungary to Algeria — for six centuries.',
    ),
    wikiRu: 'Дворец Топкапы',
    wikiEn: 'Topkapı Palace',
  ),
  Site(
    id: 'selimiye',
    name: L10nText('Мечеть Селимие', 'Selimiye Camii', 'Selimiye Mosque'),
    region: L10nText('Эдирне', 'Edirne', 'Edirne'),
    date: L10nText('1575 г.', 'MS 1575', 'AD 1575'),
    era: Era.ottoman,
    unesco: 2011,
    sortYear: 1575,
    desc: L10nText(
      'Вершина гения Синана: четыре минарета по 71 метру, купол диаметром 31 метр на четырёх колоннах, мрамор и изникская плитка.',
      'Mimar Sinan\'ın zirvesi: 71 metrelik dört minare, dört sütuna oturan 31 metre çapında kubbe, mermer ve İznik çinileri.',
      'The peak of Sinan\'s genius: four 71-metre minarets, a 31-metre dome resting on four columns, marble and İznik tiles.',
    ),
    pride: L10nText(
      'Синан построил более 300 сооружений; Селимие он называл шедевром своей зрелости.',
      'Sinan 300\'den fazla eser verdi; Selimiye\'yi "ustalık eserim" diye andı.',
      'Sinan created over 300 works; he called Selimiye his masterwork.',
    ),
    wikiRu: 'Мечеть Селимие',
    wikiEn: 'Selimiye Mosque, Edirne',
  ),
  Site(
    id: 'dolmabahce',
    name: L10nText('Дворец Долмабахче', 'Dolmabahçe Sarayı', 'Dolmabahçe Palace'),
    region: L10nText('Истанбул', 'İstanbul', 'İstanbul'),
    date: L10nText('1856 г.', 'MS 1856', 'AD 1856'),
    era: Era.ottoman,
    sortYear: 1856,
    desc: L10nText(
      '285 комнат, 43 зала, самая большая в мире хрустальная люстра и хрустальная лестница. Здесь часы остановились на 09:05 — часе смерти Ататюрка.',
      '285 oda, 43 salon, dünyanın en büyük kristal avizesi ve kristal merdiven. 10 Kasım 1938\'de, Atatürk\'ün vefat saatinde buradaki saatler 09.05\'te durdu.',
      '285 rooms, 43 halls, the world\'s largest crystal chandelier and a crystal staircase. Here the clocks stopped at 09:05 — the hour of Atatürk\'s death.',
    ),
    pride: L10nText(
      'Место, где сама история Республики остановила часы.',
      'Cumhuriyet tarihinin saatlerini durdurduğu yer.',
      'The place where the Republic\'s history stopped the clocks.',
    ),
    wikiRu: 'Дворец Долмабахче',
    wikiEn: 'Dolmabahçe Palace',
  ),
  Site(
    id: 'anitkabir',
    name: L10nText('Аныткабир', 'Anıtkabir', 'Anıtkabir'),
    region: L10nText('Анкара', 'Ankara', 'Ankara'),
    date: L10nText('1953 г.', 'MS 1953', 'AD 1953'),
    era: Era.republic,
    featured: true,
    sortYear: 1953,
    desc: L10nText(
      'Мавзолей Ататюрка: 52-метровая колоннада, «Дорога львов» из 24 каменных львов в хеттском стиле, музей Войны за независимость. Каждое 10 ноября в 09:05 страна замирает.',
      'Atatürk\'ün mozolesi: 52 metrelik sütunlar, Hitit tarzında 24 taş aslanlı Aslanlı Yol, Kurtuluş Savaşı Müzesi. Her 10 Kasım saat 09.05\'te ülke bir dakika sessizliğe gömülür.',
      'Atatürk\'s mausoleum: a 52-metre colonnade, the Road of Lions with 24 Hittite-style stone lions, the War of Independence museum. Every 10 November at 09:05 the nation falls silent.',
    ),
    pride: L10nText(
      'Хеттские львы и современный модернизм в одном монументе — 10 000 лет истории в камне.',
      'Hitit aslanları ve modern mimari tek abidede — taşta 10.000 yıllık tarih.',
      'Hittite lions and modern architecture in one monument — 10,000 years of history in stone.',
    ),
    wikiRu: 'Аныткабир',
    wikiEn: 'Anıtkabir',
  ),
];

const List<TimelineEntry> kTimeline = [
  TimelineEntry(-9500, L10nText('Гёбекли-Тепе — первый храм человечества', 'Göbekli Tepe — insanlığın ilk tapınağı', 'Göbekli Tepe — humanity\'s first temple')),
  TimelineEntry(-7100, L10nText('Чатал-Хююк — рождение города', 'Çatalhöyük — kentin doğuşu', 'Çatalhöyük — the birth of the city')),
  TimelineEntry(-1650, L10nText('Хетты — Хаттуса', 'Hititler — Hattuşa', 'The Hittites — Hattusa')),
  TimelineEntry(-1250, L10nText('Троянская война', 'Truva Savaşı', 'The Trojan War')),
  TimelineEntry(-550, L10nText('Ликийский союз — ранняя демократия', 'Likya Birliği — erken demokrasi', 'The Lycian League — early democracy')),
  TimelineEntry(537, L10nText('Айя-София', 'Ayasofya', 'Hagia Sophia')),
  TimelineEntry(1071, L10nText('Манцикерт — сельджуки в Анатолии', 'Malazgirt — Anadolu\'da Selçuklular', 'Manzikert — the Seljuks in Anatolia')),
  TimelineEntry(1453, L10nText('Стамбул становится османским', 'İstanbul Osmanlı\'nın olur', 'Istanbul becomes Ottoman')),
  TimelineEntry(1923, L10nText('Провозглашение Республики', 'Cumhuriyet ilan edilir', 'The Republic is proclaimed')),
];
