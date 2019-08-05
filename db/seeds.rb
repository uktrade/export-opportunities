raise if Rails.env.production?

require 'factory_bot_rails'
require 'faker'
I18n.reload! # Faker translations need reloading: https://github.com/stympy/faker/issues/278

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

# Build all sensible countries...
Country.create(slug: 'bolivia', name: 'Bolivia')
Country.create(slug: 'cambodia', name: 'Cambodia')
Country.create(slug: 'cameroon', name: 'Cameroon')
Country.create(slug: 'dominican-republic', name: 'Dominican Republic')
Country.create(slug: 'el-salvador', name: 'El Salvador')
Country.create(slug: 'gabon', name: 'Gabon')
Country.create(slug: 'guinea', name: 'Guinea')
Country.create(slug: 'ivory-coast', name: 'Ivory Coast')
Country.create(slug: 'macedonia', name: 'Macedonia')
Country.create(slug: 'nepal', name: 'Nepal')
Country.create(slug: 'palestinian-territories', name: 'Palestinian Territories')
Country.create(slug: 'papua-new-guinea', name: 'Papua New Guinea')
Country.create(slug: 'senegal', name: 'Senegal')
Country.create(slug: 'seychelles', name: 'Seychelles')
Country.create(slug: 'sierra-leone', name: 'Sierra Leone')
Country.create(slug: 'turkmenistan', name: 'Turkmenistan')
Country.create(slug: 'zambia', name: 'Zambia')
Country.create(slug: 'armenia', name: 'Armenia')
Country.create(slug: 'tajikistan', name: 'Tajikistan')
Country.create(slug: 'zimbabwe', name: 'Zimbabwe')
Country.create(slug: 'guinea-bissau', name: 'Guinea-Bissau')
Country.create(slug: 'albania', name: 'Albania')
Country.create(slug: 'togo', name: 'Togo')
Country.create(slug: 'east-timor', name: 'East Timor')
Country.create(slug: 'sudan', name: 'Sudan')
Country.create(slug: 'kosovo', name: 'Kosovo')
Country.create(slug: 'mali', name: 'Mali')
Country.create(slug: 'somalia', name: 'Somalia')
Country.create(slug: 'solomen-islands', name: 'Solomon Islands')
Country.create(slug: 'belarus', name: 'Belarus')
Country.create(slug: 'moldova', name: 'Moldova')
Country.create(slug: 'montenegro', name: 'Montenegro')
Country.create(slug: 'sao-tome-and-principe', name: 'Sao Tome and Principe')
Country.create(slug: 'kyrgyzstan', name: 'Kyrgyzstan')
Country.create(slug: 'lesotho', name: 'Lesotho')
Country.create(slug: 'liberia', name: 'Liberia')
Country.create(slug: 'georgia', name: 'Georgia')
Country.create(slug: 'botswana', name: 'Botswana')
Country.create(slug: 'malawi', name: 'Malawi')
Country.create(slug: 'namibia', name: 'Namibia')
Country.create(slug: 'luxembourg', name: 'Luxembourg')
Country.create(slug: 'nato', name: 'NATO')
Country.create(slug: 'uzbekistan', name: 'Uzbekistan')
Country.create(slug: 'dominica', name: 'Dominica')
Country.create(slug: 'austria', name: 'Austria', exporting_guide_path: '/government/publications/exporting-to-austria')
Country.create(slug: 'azerbaijan', name: 'Azerbaijan', exporting_guide_path: '/government/publications/exporting-to-azerbaijan')
Country.create(slug: 'hong-kong', name: 'Hong Kong', exporting_guide_path: '/government/publications/exporting-to-hong-kong')
Country.create(slug: 'hungary', name: 'Hungary', exporting_guide_path: '/government/publications/exporting-to-hungary')
Country.create(slug: 'iceland', name: 'Iceland', exporting_guide_path: '/government/publications/exporting-to-iceland')
Country.create(slug: 'india', name: 'India', exporting_guide_path: '/government/publications/exporting-to-india')
Country.create(slug: 'indonesia', name: 'Indonesia', exporting_guide_path: '/government/publications/exporting-to-indonesia')
Country.create(slug: 'iraq', name: 'Iraq', exporting_guide_path: '/government/publications/exporting-to-iraq')
Country.create(slug: 'ireland', name: 'Ireland', exporting_guide_path: '/government/publications/exporting-to-ireland')
Country.create(slug: 'israel', name: 'Israel', exporting_guide_path: '/government/publications/exporting-to-israel')
Country.create(slug: 'jamaica', name: 'Jamaica', exporting_guide_path: '/government/publications/exporting-to-jamaica')
Country.create(slug: 'japan', name: 'Japan', exporting_guide_path: '/government/publications/exporting-to-japan')
Country.create(slug: 'jordan', name: 'Jordan', exporting_guide_path: '/government/publications/exporting-to-jordan')
Country.create(slug: 'kazakhstan', name: 'Kazakhstan', exporting_guide_path: '/government/publications/exporting-to-kazakhstan')
Country.create(slug: 'kenya', name: 'Kenya', exporting_guide_path: '/government/publications/exporting-to-kenya')
Country.create(slug: 'kuwait', name: 'Kuwait', exporting_guide_path: '/government/publications/exporting-to-kuwait')
Country.create(slug: 'latvia', name: 'Latvia', exporting_guide_path: '/government/publications/exporting-to-latvia')
Country.create(slug: 'panama', name: 'Panama', exporting_guide_path: '/government/publications/exporting-to-panama')
Country.create(slug: 'peru', name: 'Peru', exporting_guide_path: '/government/publications/exporting-to-peru')
Country.create(slug: 'the-philippines', name: 'Philippines', exporting_guide_path: '/government/publications/exporting-to-the-philippines')
Country.create(slug: 'poland', name: 'Poland', exporting_guide_path: '/government/publications/exporting-to-poland')
Country.create(slug: 'portugal', name: 'Portugal', exporting_guide_path: '/government/publications/exporting-to-portugal')
Country.create(slug: 'qatar', name: 'Qatar', exporting_guide_path: '/government/publications/exporting-to-qatar')
Country.create(slug: 'romania', name: 'Romania', exporting_guide_path: '/government/publications/exporting-to-romania')
Country.create(slug: 'russia', name: 'Russia', exporting_guide_path: '/government/publications/exporting-to-russia')
Country.create(slug: 'saudi-arabia', name: 'Saudi Arabia', exporting_guide_path: '/government/publications/exporting-to-saudi-arabia')
Country.create(slug: 'serbia', name: 'Serbia', exporting_guide_path: '/government/publications/exporting-to-serbia')
Country.create(slug: 'singapore', name: 'Singapore', exporting_guide_path: '/government/publications/exporting-to-singapore')
Country.create(slug: 'slovakia', name: 'Slovakia', exporting_guide_path: '/government/publications/exporting-to-slovakia')
Country.create(slug: 'slovenia', name: 'Slovenia', exporting_guide_path: '/government/publications/exporting-to-slovenia')
Country.create(slug: 'south-africa', name: 'South Africa', exporting_guide_path: '/government/publications/exporting-to-south-africa')
Country.create(slug: 'south-korea', name: 'South Korea', exporting_guide_path: '/government/publications/exporting-to-south-korea')
Country.create(slug: 'rwanda', name: 'Rwanda', exporting_guide_path: '/government/publications/exporting-to-rwanda')
Country.create(slug: 'macao', name: 'Macao', exporting_guide_path: '/government/publications/exporting-to-macao')
Country.create(slug: 'st-vincent', name: 'St Vincent')
Country.create(slug: 'st-lucia', name: 'St Lucia')
Country.create(slug: 'belize', name: 'Belize')
Country.create(slug: 'grenada', name: 'Grenada')
Country.create(slug: 'british-virgin-islands', name: 'British Virgin Islands')
Country.create(slug: 'bhutan', name: 'Bhutan')
Country.create(slug: 'chad', name: 'Chad')
Country.create(slug: 'samoa', name: 'Samoa')
Country.create(slug: 'uruguay', name: 'Uruguay')
Country.create(slug: 'surinam', name: 'Surinam')
Country.create(slug: 'benin', name: 'Benin')
Country.create(slug: 'bahamas', name: 'Bahamas')
Country.create(slug: 'democratic-republic-of-congo', name: 'Democratic Republic of Congo')
Country.create(slug: 'mauritania', name: 'Mauritania')
Country.create(slug: 'south-sudan', name: 'South Sudan')
Country.create(slug: 'paraguay', name: 'Paraguay')
Country.create(slug: 'myanmar', name: 'Myanmar')
Country.create(slug: 'madagascar', name: 'Madagascar')
Country.create(slug: 'swaziland', name: 'Swaziland')
Country.create(slug: 'afghanistan', name: 'Afghanistan', exporting_guide_path: '/government/publications/exporting-to-afghanistan')
Country.create(slug: 'algeria', name: 'Algeria', exporting_guide_path: '/government/publications/exporting-to-algeria')
Country.create(slug: 'angola', name: 'Angola', exporting_guide_path: '/government/publications/exporting-to-angola')
Country.create(slug: 'argentina', name: 'Argentina', exporting_guide_path: '/government/publications/exporting-to-argentina')
Country.create(slug: 'australia', name: 'Australia', exporting_guide_path: '/government/publications/exporting-to-australia')
Country.create(slug: 'bahrain', name: 'Bahrain', exporting_guide_path: '/government/publications/exporting-to-bahrain')
Country.create(slug: 'bangladesh', name: 'Bangladesh', exporting_guide_path: '/government/publications/exporting-to-bangladesh')
Country.create(slug: 'barbados', name: 'Barbados', exporting_guide_path: '/government/publications/exporting-to-barbados')
Country.create(slug: 'belgium', name: 'Belgium', exporting_guide_path: '/government/publications/exporting-to-belgium')
Country.create(slug: 'bosnia-and-herzegovina', name: 'Bosnia and Herzegovina', exporting_guide_path: '/government/publications/exporting-to-bosnia-and-herzegovina')
Country.create(slug: 'brazil', name: 'Brazil', exporting_guide_path: '/government/publications/exporting-to-brazil')
Country.create(slug: 'brunei', name: 'Brunei', exporting_guide_path: '/government/publications/exporting-to-brunei')
Country.create(slug: 'bulgaria', name: 'Bulgaria', exporting_guide_path: '/government/publications/exporting-to-bulgaria')
Country.create(slug: 'burma', name: 'Burma', exporting_guide_path: '/government/publications/exporting-to-burma')
Country.create(slug: 'canada', name: 'Canada', exporting_guide_path: '/government/publications/exporting-to-canada')
Country.create(slug: 'chile', name: 'Chile', exporting_guide_path: '/government/publications/exporting-to-chile')
Country.create(slug: 'china', name: 'China', exporting_guide_path: '/government/publications/exporting-to-china')
Country.create(slug: 'colombia', name: 'Colombia', exporting_guide_path: '/government/publications/exporting-to-colombia')
Country.create(slug: 'costa-rica', name: 'Costa Rica', exporting_guide_path: '/government/publications/exporting-to-costa-rica')
Country.create(slug: 'croatia', name: 'Croatia', exporting_guide_path: '/government/publications/exporting-to-croatia')
Country.create(slug: 'cuba', name: 'Cuba', exporting_guide_path: '/government/publications/exporting-to-cuba')
Country.create(slug: 'cyprus', name: 'Cyprus', exporting_guide_path: '/government/publications/exporting-to-cyprus')
Country.create(slug: 'czech-republic', name: 'Czech Republic', exporting_guide_path: '/government/publications/exporting-to-czech-republic')
Country.create(slug: 'denmark', name: 'Denmark', exporting_guide_path: '/government/publications/exporting-to-denmark')
Country.create(slug: 'ecuador', name: 'Ecuador', exporting_guide_path: '/government/publications/exporting-to-ecuador')
Country.create(slug: 'egypt', name: 'Egypt', exporting_guide_path: '/government/publications/exporting-to-egypt')
Country.create(slug: 'estonia', name: 'Estonia', exporting_guide_path: '/government/publications/exporting-to-estonia')
Country.create(slug: 'ethiopia', name: 'Ethiopia', exporting_guide_path: '/government/publications/exporting-to-ethiopia')
Country.create(slug: 'finland', name: 'Finland', exporting_guide_path: '/government/publications/exporting-to-finland')
Country.create(slug: 'germany', name: 'Germany', exporting_guide_path: '/government/publications/exporting-to-germany')
Country.create(slug: 'ghana', name: 'Ghana', exporting_guide_path: '/government/publications/exporting-to-ghana')
Country.create(slug: 'greece', name: 'Greece', exporting_guide_path: '/government/publications/exporting-to-greece')
Country.create(slug: 'guyana', name: 'Guyana', exporting_guide_path: '/government/publications/exporting-to-guyana')
Country.create(slug: 'lebanon', name: 'Lebanon', exporting_guide_path: '/government/publications/exporting-to-lebanon')
Country.create(slug: 'libya', name: 'Libya', exporting_guide_path: '/government/publications/exporting-to-libya')
Country.create(slug: 'lithuania', name: 'Lithuania', exporting_guide_path: '/government/publications/exporting-to-lithuania')
Country.create(slug: 'malaysia', name: 'Malaysia', exporting_guide_path: '/government/publications/exporting-to-malaysia')
Country.create(slug: 'mauritius', name: 'Mauritius', exporting_guide_path: '/government/publications/exporting-to-mauritius')
Country.create(slug: 'mexico', name: 'Mexico', exporting_guide_path: '/government/publications/exporting-to-mexico')
Country.create(slug: 'mongolia', name: 'Mongolia', exporting_guide_path: '/government/publications/exporting-to-mongolia')
Country.create(slug: 'morocco', name: 'Morocco', exporting_guide_path: '/government/publications/exporting-to-morocco')
Country.create(slug: 'mozambique', name: 'Mozambique', exporting_guide_path: '/government/publications/exporting-to-mozambique')
Country.create(slug: 'netherlands', name: 'Netherlands', exporting_guide_path: '/government/publications/exporting-to-netherlands')
Country.create(slug: 'new-zealand', name: 'New Zealand', exporting_guide_path: '/government/publications/exporting-to-new-zealand')
Country.create(slug: 'nigeria', name: 'Nigeria', exporting_guide_path: '/government/publications/exporting-to-nigeria')
Country.create(slug: 'norway', name: 'Norway', exporting_guide_path: '/government/publications/exporting-to-norway')
Country.create(slug: 'oman', name: 'Oman', exporting_guide_path: '/government/publications/exporting-to-oman')
Country.create(slug: 'pakistan', name: 'Pakistan', exporting_guide_path: '/government/publications/exporting-to-pakistan')
Country.create(slug: 'spain', name: 'Spain', exporting_guide_path: '/government/publications/exporting-to-spain')
Country.create(slug: 'sri-lanka', name: 'Sri Lanka', exporting_guide_path: '/government/publications/exporting-to-sri-lanka')
Country.create(slug: 'sweden', name: 'Sweden', exporting_guide_path: '/government/publications/exporting-to-sweden')
Country.create(slug: 'switzerland', name: 'Switzerland', exporting_guide_path: '/government/publications/exporting-to-switzerland')
Country.create(slug: 'taiwan', name: 'Taiwan', exporting_guide_path: '/government/publications/exporting-to-taiwan')
Country.create(slug: 'tanzania', name: 'Tanzania', exporting_guide_path: '/government/publications/exporting-to-tanzania')
Country.create(slug: 'thailand', name: 'Thailand', exporting_guide_path: '/government/publications/exporting-to-thailand')
Country.create(slug: 'trinidad-and-tobago', name: 'Trinidad and Tobago', exporting_guide_path: '/government/publications/exporting-to-trinidad-and-tobago')
Country.create(slug: 'tunisia', name: 'Tunisia', exporting_guide_path: '/government/publications/exporting-to-tunisia')
Country.create(slug: 'turkey', name: 'Turkey', exporting_guide_path: '/government/publications/exporting-to-turkey')
Country.create(slug: 'the-united-arab-emirates', name: 'UAE', exporting_guide_path: '/government/publications/exporting-to-the-united-arab-emirates')
Country.create(slug: 'uganda', name: 'Uganda', exporting_guide_path: '/government/publications/exporting-to-uganda')
Country.create(slug: 'ukraine', name: 'Ukraine', exporting_guide_path: '/government/publications/exporting-to-ukraine')
Country.create(slug: 'the-usa', name: 'USA', exporting_guide_path: '/government/publications/exporting-to-the-usa')
Country.create(slug: 'venezuela', name: 'Venezuela', exporting_guide_path: '/government/publications/exporting-to-venezuela')
Country.create(slug: 'vietnam', name: 'Vietnam', exporting_guide_path: '/government/publications/exporting-to-vietnam')

Sector.create(slug: 'aerospace', name: 'Aerospace')
Sector.create(slug: 'airports', name: 'Airports')
Sector.create(slug: 'biotechnology-pharmaceuticals', name: 'Biotechnology & Pharmaceuticals')
Sector.create(slug: 'business-consumer-services', name: 'Business & Consumer Services')
Sector.create(slug: 'chemicals', name: 'Chemicals')
Sector.create(slug: 'clothing-footwear-fashion', name: 'Clothing, Footwear & Fashion')
Sector.create(slug: 'communications', name: 'Communications')
Sector.create(slug: 'construction', name: 'Construction')
Sector.create(slug: 'creative-media', name: 'Creative & Media')
Sector.create(slug: 'education-training', name: 'Education & Training')
Sector.create(slug: 'electronics-it-hardware', name: 'Electronics & IT Hardware')
Sector.create(slug: 'environment', name: 'Environment')
Sector.create(slug: 'financial-professional-services', name: 'Financial & Professional Services')
Sector.create(slug: 'food-drink', name: 'Food & Drink')
Sector.create(slug: 'giftware-jewellery-tableware', name: 'Giftware, Jewellery & Tableware')
Sector.create(slug: 'global-sports-infrastructure', name: 'Global Sports Infrastructure')
Sector.create(slug: 'healthcare-medical', name: 'Healthcare & Medical')
Sector.create(slug: 'household-goods-furniture-furnishings', name: 'Household Goods, Furniture & Furnishings')
Sector.create(slug: 'leisure-tourism', name: 'Leisure & Tourism')
Sector.create(slug: 'marine', name: 'Marine')
Sector.create(slug: 'mechanical-electrical-process-engineering', name: 'Mechanical Electrical & Process Engineering')
Sector.create(slug: 'metallurgical-process-plant', name: 'Metallurgical Process Plant')
Sector.create(slug: 'metals-minerals-materials', name: 'Metals, Minerals & Materials')
Sector.create(slug: 'mining', name: 'Mining')
Sector.create(slug: 'oil-gas', name: 'Oil & Gas')
Sector.create(slug: 'ports-logistics', name: 'Ports & Logistics')
Sector.create(slug: 'power', name: 'Power')
Sector.create(slug: 'railways', name: 'Railways')
Sector.create(slug: 'renewable-energy', name: 'Renewable Energy')
Sector.create(slug: 'retail-and-luxury', name: 'Retail and Luxury')
Sector.create(slug: 'security', name: 'Security')
Sector.create(slug: 'software-computer-services', name: 'Software & Computer Services')
Sector.create(slug: 'textiles-interior-textiles-carpets', name: 'Textiles, Interior Textiles & Carpets')
Sector.create(slug: 'water', name: 'Water')

Sector.find_by(slug: 'creative-media').try(:update, featured: true, featured_order: 1)
Sector.find_by(slug: 'education-training').try(:update, featured: true, featured_order: 2)
Sector.find_by(slug: 'food-drink').try(:update, featured: true, featured_order: 3)
Sector.find_by(slug: 'oil-gas').try(:update, featured: true, featured_order: 4)
Sector.find_by(slug: 'security').try(:update, featured: true, featured_order: 5)
Sector.find_by(slug: 'retail-and-luxury').try(:update, featured: true, featured_order: 6)

Type.where(slug: 'aid-funded-business', name: 'Aid Funded Business').first_or_create
Type.where(slug: 'public-sector', name: 'Public Sector').first_or_create

Value.where(slug: '10k', name: 'Less than £100k').first_or_create
Value.where(slug: 'unknown', name: 'Value unknown').first_or_create

ServiceProvider.create(name: 'Belgium Brussels')
ServiceProvider.create(name: 'Australia Sydney')
ServiceProvider.create(name: 'Vietnam Ho Chi Minh City')
ServiceProvider.create(name: 'United States New York')
ServiceProvider.create(name: 'United States Washington DC')
ServiceProvider.create(name: 'Ukraine Kyiv')
ServiceProvider.create(name: 'United Arab Emirates Dubai')
ServiceProvider.create(name: 'Turkey Izmir')
ServiceProvider.create(name: 'UKREP')
ServiceProvider.create(name: 'Thailand Bangkok')
ServiceProvider.create(name: 'Taiwan Taipei')
ServiceProvider.create(name: 'Sweden Stockholm')
ServiceProvider.create(name: 'Spain Madrid')
ServiceProvider.create(name: 'Cambodia Phnom Penh')
ServiceProvider.create(name: 'Australia Melbourne')
ServiceProvider.create(name: 'Spain Barcelona')
ServiceProvider.create(name: 'BLANK Belgium')
ServiceProvider.create(name: 'Brazil Rio de Janeiro')
ServiceProvider.create(name: 'Russia Moscow')
ServiceProvider.create(name: 'Norway Oslo')
ServiceProvider.create(name: 'Romania Bucharest')
ServiceProvider.create(name: 'Portugal Lisboa')
ServiceProvider.create(name: 'Poland Warsaw')
ServiceProvider.create(name: 'Philippines Manila')
ServiceProvider.create(name: 'Peru Lima')
ServiceProvider.create(name: 'Nigeria Lagos')
ServiceProvider.create(name: 'USA AFB')
ServiceProvider.create(name: 'Indonesia Jakarta')
ServiceProvider.create(name: 'Kuwait Kuwait')
ServiceProvider.create(name: 'South Africa Johannesburg')
ServiceProvider.create(name: 'Tanzania Dar es Salaam')
ServiceProvider.create(name: 'Colombia Bogotá, D.C')
ServiceProvider.create(name: 'Denmark Copenhagen')
ServiceProvider.create(name: 'Canada Toronto')
ServiceProvider.create(name: 'Brazil Porto Alegre-RS')
ServiceProvider.create(name: 'Singapore Singapore')
ServiceProvider.create(name: 'China - CBBC')
ServiceProvider.create(name: 'Ethiopia Addis Ababa')
ServiceProvider.create(name: 'India Kolkata')
ServiceProvider.create(name: 'Canada Vancouver')
ServiceProvider.create(name: 'India New Delhi')
ServiceProvider.create(name: 'Chile OBNI')
ServiceProvider.create(name: 'Hong Kong (SAR) Hong Kong')
ServiceProvider.create(name: 'United States Los Angeles')
ServiceProvider.create(name: 'Turkey Ankara')
ServiceProvider.create(name: 'Mexico Mexico City')
ServiceProvider.create(name: 'Vietnam Hanoi')
ServiceProvider.create(name: 'Japan Tokyo')
ServiceProvider.create(name: 'India Mumbai')
ServiceProvider.create(name: 'India Bangalore')
ServiceProvider.create(name: 'Brazil Sao Paulo')
ServiceProvider.create(name: 'Argentina Buenos Aires')
ServiceProvider.create(name: 'China Beijing')
ServiceProvider.create(name: 'Austria Vienna')
ServiceProvider.create(name: 'Malaysia Kuala Lumpur')
ServiceProvider.create(name: 'Brazil Recife')
ServiceProvider.create(name: 'Bahrain Manama')
ServiceProvider.create(name: 'Australia Perth')
ServiceProvider.create(name: 'Azerbaijan Azerbaijan')
ServiceProvider.create(name: 'Israel Tel Aviv')
ServiceProvider.create(name: 'Brazil Conjunto K Brasilia')
ServiceProvider.create(name: 'Japan Osaka')
ServiceProvider.create(name: 'Costa Rica San Jose')
ServiceProvider.create(name: 'Croatia Zagreb')
ServiceProvider.create(name: 'Trinidad and Tobago Port of Spain')
ServiceProvider.create(name: 'Cuba Havana')
ServiceProvider.create(name: 'Cyprus Nicosia')
ServiceProvider.create(name: 'Czech Republic Prague')
ServiceProvider.create(name: 'Bangladesh Dhaka')
ServiceProvider.create(name: 'Egypt Cairo')
ServiceProvider.create(name: 'Korea (South) Seoul')
ServiceProvider.create(name: 'Saudi Arabia Jeddah')
ServiceProvider.create(name: 'Qatar Doha')
ServiceProvider.create(name: 'Mexico Tijuana')
ServiceProvider.create(name: 'Kazakhstan Astana')
ServiceProvider.create(name: 'Estonia Tallinn')
ServiceProvider.create(name: 'United Arab Emirates Abu Dhabi')
ServiceProvider.create(name: 'Jamaica Kingston')
ServiceProvider.create(name: 'Saudi Arabia Al Khobar')
ServiceProvider.create(name: 'Finland Helsinki')
ServiceProvider.create(name: 'Bosnia and Herzegovina Sarajevo')
ServiceProvider.create(name: 'Chile Santiago')
ServiceProvider.create(name: 'Turkey Istanbul')
ServiceProvider.create(name: 'Lithuania Vilnius')
ServiceProvider.create(name: 'Mozambique Maputo City')
ServiceProvider.create(name: 'France Bordeaux')
ServiceProvider.create(name: 'France Lyon')
ServiceProvider.create(name: 'Pakistan Karachi')
ServiceProvider.create(name: 'New Zealand Auckland')
ServiceProvider.create(name: 'Netherlands The Hague')
ServiceProvider.create(name: 'Germany Düsseldorf')
ServiceProvider.create(name: 'Germany Munich')
ServiceProvider.create(name: 'Greece Athens')
ServiceProvider.create(name: 'Hungary Budapest')
ServiceProvider.create(name: 'Iceland Reykjavík')
ServiceProvider.create(name: 'India Chennai')
ServiceProvider.create(name: 'Italy Rome')
ServiceProvider.create(name: 'Germany Berlin')
ServiceProvider.create(name: 'Italy Milan')
ServiceProvider.create(name: 'Mongolia Ulaanbaatar')
ServiceProvider.create(name: 'Morocco Casablanca')
ServiceProvider.create(name: 'United States Miami')
ServiceProvider.create(name: 'Bulgaria Sofia')
ServiceProvider.create(name: 'Zambia Lusaka')
ServiceProvider.create(name: 'Iraq Baghdad')
ServiceProvider.create(name: 'DSO RD West 2 / NATO')
ServiceProvider.create(name: 'Panama Panama City')
ServiceProvider.create(name: 'Ireland Dublin')
ServiceProvider.create(name: 'Kenya Nairobi')
ServiceProvider.create(name: 'Luxembourg Luxembourg')
ServiceProvider.create(name: 'Slovakia Bratislava')
ServiceProvider.create(name: 'Pakistan Islamabad')
ServiceProvider.create(name: 'Switzerland Geneva')
ServiceProvider.create(name: 'Mexico Monterrey')
ServiceProvider.create(name: 'Slovenia Ljubljana')
ServiceProvider.create(name: 'Egypt Roushdy')
ServiceProvider.create(name: 'Latvia Riga')
ServiceProvider.create(name: 'Oman Muscat')
ServiceProvider.create(name: 'United States Houston')
ServiceProvider.create(name: 'Seychelles Victoria')
ServiceProvider.create(name: 'Russia St Petersburg')
ServiceProvider.create(name: 'Guyana Georgetown')
ServiceProvider.create(name: 'Australia Canberra')
ServiceProvider.create(name: 'Australia Brisbane')
ServiceProvider.create(name: 'Jordan Jordan')
ServiceProvider.create(name: 'Namibia Windhoek')
ServiceProvider.create(name: 'Colombia OBNI')
ServiceProvider.create(name: 'United States Chicago')
ServiceProvider.create(name: 'United States Atlanta')
ServiceProvider.create(name: 'Vietnam OBNI')
ServiceProvider.create(name: 'United Kingdom LONDON')
ServiceProvider.create(name: 'United States San Francisco')
ServiceProvider.create(name: 'Czech Republic OBNI')
ServiceProvider.create(name: 'Burma Rangoon')
ServiceProvider.create(name: 'Canada Calgary')
ServiceProvider.create(name: 'Pakistan Lahore')
ServiceProvider.create(name: 'Uzbekistan Tashkent')
ServiceProvider.create(name: 'Serbia Belgrade')
ServiceProvider.create(name: 'India Hyderabad')
ServiceProvider.create(name: 'South Africa Cape Town')
ServiceProvider.create(name: 'Mauritius Port Louis')
ServiceProvider.create(name: 'Barbados Bridgetown')
ServiceProvider.create(name: 'Slovakia OBNI')
ServiceProvider.create(name: 'Algeria Algiers')
ServiceProvider.create(name: 'Ecuador Quito')
ServiceProvider.create(name: 'Switzerland Berne')
ServiceProvider.create(name: 'Russia Ekaterinburg')
ServiceProvider.create(name: 'Ghana Ghana')
ServiceProvider.create(name: 'Dominican Republic Santo Domingo')
ServiceProvider.create(name: 'DIT HQ')
ServiceProvider.create(name: 'Armenia Yerevan')
ServiceProvider.create(name: 'Occupied Palestinian Territories Jerusalem')
ServiceProvider.create(name: 'Saudi Arabia Riyadh')
ServiceProvider.create(name: 'Tunisia Tunis')
ServiceProvider.create(name: 'Angola Luanda')
ServiceProvider.create(name: 'DSO HQ')
ServiceProvider.create(name: 'Slovenia OBNI')
ServiceProvider.create(name: 'Malaysia OBNI')
ServiceProvider.create(name: 'Hungary OBNI')
ServiceProvider.create(name: 'Canada Montreal')
ServiceProvider.create(name: 'Iraq Erbil')
ServiceProvider.create(name: 'Romania OBNI')
ServiceProvider.create(name: 'Afghanistan Kabul')
ServiceProvider.create(name: 'Morocco OBNI')
ServiceProvider.create(name: 'Taiwan OBNI')
ServiceProvider.create(name: 'India Chandigarh')
ServiceProvider.create(name: 'India Ahmedabad')
ServiceProvider.create(name: 'Indonesia OBNI')
ServiceProvider.create(name: 'Lebanon Lebanon')
ServiceProvider.create(name: 'United States Cambridge')
ServiceProvider.create(name: 'Poland OBNI')
ServiceProvider.create(name: 'Georgia Tbilisi')
ServiceProvider.create(name: 'Thailand OBNI')
ServiceProvider.create(name: 'United Arab Emirates OBNI')
ServiceProvider.create(name: 'Uganda Kampala')
ServiceProvider.create(name: 'Bolivia La Paz')
ServiceProvider.create(name: 'Macedonia Skopje')
ServiceProvider.create(name: 'Canada Ottawa')
ServiceProvider.create(name: 'India Pune')
ServiceProvider.create(name: 'Libya Tripoli')
ServiceProvider.create(name: 'Turkmenistan Ashgabat')
ServiceProvider.create(name: 'Belo Horizonte')
ServiceProvider.create(name: 'India OBNI')
ServiceProvider.create(name: 'Kenya OBNI')
ServiceProvider.create(name: 'Pakistan OBNI')
ServiceProvider.create(name: 'Kathmandu, Nepal')
ServiceProvider.create(name: 'Bandar Seri Begawan, Brunei')
ServiceProvider.create(name: 'DIT Education')
ServiceProvider.create(name: 'Colombo Sri Lanka')
ServiceProvider.create(name: 'Rwanda, Kigali')
ServiceProvider.create(name: 'Venezuela Caracas')

# Prime the database with basic content
france = Country.where(slug: 'france', name: 'France', exporting_guide_path: '/government/publications/exporting-to-france').first_or_create
italy = Country.where(slug: 'italy', name: 'Italy', exporting_guide_path: '/government/publications/exporting-to-italy').first_or_create

naples = ServiceProvider.where(name: 'Italy Naples').first_or_create
paris = ServiceProvider.where(name: 'France Paris').first_or_create

editor = FactoryBot.create(:editor,
  email: 'email@example.com',
  password: 'wintles is coming',
  name: 'John Doe',
  wordpress_id: '1',
  service_provider: paris,
  confirmed_at: DateTime.current,
  role: 4)

FactoryBot.create(:editor,
  email: 'uploader@example.com',
  password: 'wintles is coming',
  name: 'Uploader Jane',
  service_provider: paris,
  confirmed_at: DateTime.current,
  role: 1)

agriculture = Sector.where(slug: 'agriculture-horticulture-fisheries', name: 'Agriculture, Horticulture & Fisheries').first_or_create
automotive = Sector.where(slug: 'automotive', name: 'Automotive').first_or_create

private_sector = Type.where(slug: 'private-sector', name: 'Private Sector').first_or_create

hundred_thousand = Value.where(slug: '100k', name: 'More than £100k').first_or_create

future_expiry_date = 2.years.from_now
past_expiry_date   = 2.weeks.ago

# Valid opportunity
valid_opportunity = FactoryBot.create(:opportunity,
  slug: 'french-sardines-required',
  title: 'French sardines required',
  response_due_on: 9.months.from_now,
  author: editor,
  service_provider: paris,
  countries: [france],
  sectors: [agriculture],
  types: [private_sector],
  values: [hundred_thousand],
  created_at: 2.weeks.ago,
  first_published_at: Time.zone.today,
  source: :post,
  status: :publish)

# Created an enquiry for a valid opportunity
FactoryBot.create(:enquiry, opportunity: valid_opportunity)

# Expired opportunity
FactoryBot.create(:opportunity,
  slug: 'italy-needs-a-porsche',
  title: 'Italy needs a porsche',
  response_due_on: 1.month.ago,
  author: editor,
  service_provider: naples,
  countries: [italy],
  sectors: [automotive],
  types: [Type.all.sample],
  values: [Value.all.sample],
  created_at: 2.months.ago,
  first_published_at: 6.weeks.ago,
  status: :publish)

FactoryBot.create(:opportunity,
  title: 'Published opportunity',
  response_due_on: future_expiry_date,
  author: editor,
  service_provider: paris,
  countries: [france],
  sectors: [agriculture],
  types: [private_sector],
  values: [hundred_thousand],
  created_at: 1.month.ago,
  first_published_at: Time.zone.now,
  status: :publish)

FactoryBot.create(:opportunity,
  title: 'Pending opportunity',
  response_due_on: future_expiry_date,
  author: editor,
  service_provider: naples,
  countries: [italy],
  sectors: [automotive],
  types: [Type.all.sample],
  values: [Value.all.sample],
  status: :pending)

FactoryBot.create(:opportunity,
  title: 'Pending opportunity that was once published',
  response_due_on: future_expiry_date,
  author: editor,
  service_provider: naples,
  countries: [italy],
  sectors: [automotive],
  types: [Type.all.sample],
  values: [Value.all.sample],
  created_at: 2.weeks.ago,
  first_published_at: 1.week.ago,
  status: :pending)

FactoryBot.create(:opportunity,
  title: 'Trashed opportunity',
  response_due_on: future_expiry_date,
  service_provider: ServiceProvider.all.sample,
  countries: [Country.all.sample],
  sectors: [Sector.all.sample],
  types: [Type.all.sample],
  values: [Value.all.sample],
  status: :trash)

FactoryBot.create(:opportunity,
  title: 'Trashed opportunity that was once published',
  response_due_on: future_expiry_date,
  service_provider: ServiceProvider.all.sample,
  countries: [Country.all.sample],
  sectors: [Sector.all.sample],
  types: [Type.all.sample],
  values: [Value.all.sample],
  created_at: 2.weeks.ago,
  first_published_at: 1.week.ago,
  status: :trash)

FactoryBot.create(:opportunity,
  title: 'Expired published opportunity',
  response_due_on: past_expiry_date,
  author: editor,
  service_provider: paris,
  countries: [france],
  sectors: [agriculture],
  types: [private_sector],
  values: [hundred_thousand],
  created_at: 2.months.ago,
  first_published_at: 1.month.ago,
  status: :publish)

FactoryBot.create(:opportunity,
  title: 'Expired pending opportunity',
  response_due_on: past_expiry_date,
  author: editor,
  service_provider: naples,
  countries: [italy],
  sectors: [automotive],
  types: [Type.all.sample],
  values: [Value.all.sample],
  status: :pending)

FactoryBot.create(:opportunity,
  title: 'Expired trashed opportunity',
  response_due_on: past_expiry_date,
  service_provider: ServiceProvider.all.sample,
  countries: [Country.all.sample],
  sectors: [Sector.all.sample],
  types: [Type.all.sample],
  values: [Value.all.sample],
  status: :trash)

FactoryBot.create(:opportunity,
  title: 'Pending opportunity from Paris service provider',
  response_due_on: future_expiry_date,
  service_provider: paris,
  countries: [Country.all.sample],
  sectors: [Sector.all.sample],
  types: [Type.all.sample],
  values: [Value.all.sample],
  status: :pending)

FactoryBot.create(:supplier_preference)
