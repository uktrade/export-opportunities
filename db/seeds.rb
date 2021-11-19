raise if Rails.env.production?

require 'factory_bot_rails'
require 'faker'
I18n.reload! # Faker translations need reloading: https://github.com/stympy/faker/issues/278

Opportunity.reset_column_information
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
Sector.create(slug: 'automotive', name: 'Automotive')
Sector.create(slug: 'chemicals', name: 'Chemicals')
Sector.create(slug: 'construction', name: 'Construction')
Sector.create(slug: 'environment', name: 'Environment')
Sector.create(slug: 'mining', name: 'Mining')
Sector.create(slug: 'railways', name: 'Railways')
Sector.create(slug: 'software-computer-services', name: 'Software & Computer Services')
Sector.create(slug: 'water', name: 'Water')
Sector.create(slug: 'security', name: 'Security')
Sector.create(slug: 'advanced-engineering', name: 'Advanced engineering')
Sector.create(slug: 'Agriculture-horticulture-fisheries-pets', name: 'Agriculture, horticulture, fisheries and pets')
Sector.create(slug: 'consumer-and-retail', name: 'Consumer and retail')
Sector.create(slug: 'creative-industries', name: 'Creative industries')
Sector.create(slug: 'education-training', name: 'Education and training')
Sector.create(slug: 'financial-and-professional-services', name: 'Financial and professional services')
Sector.create(slug: 'food-and-drink', name: 'Food and drink')
Sector.create(slug: 'healthcare-services', name: 'Healthcare services')
Sector.create(slug: 'maritime', name: 'Maritime')
Sector.create(slug: 'pharmaceuticals-and-biotechnology', name: 'Pharmaceuticals and biotechnology')
Sector.create(slug: 'sports-economy', name: 'Sports economy')
Sector.create(slug: 'Space', name: 'Space')
Sector.create(slug: 'defence', name: 'Defence')
Sector.create(slug: 'energy', name: 'Energy')
Sector.create(slug: 'medical-devices-equipment', name: 'Medical devices and equipment')
Sector.create(slug: 'business-consumer-services', name: 'Business & Consumer Services')
Sector.create(slug: 'clothing-footwear-fashion', name: 'Clothing, Footwear & Fashion')
Sector.create(slug: 'communications', name: 'Communications')
Sector.create(slug: 'civil-nuclear', name: 'Civil Nuclear')
Sector.create(slug: 'electronics-it-hardware', name: 'Electronics & IT Hardware')
Sector.create(slug: 'giftware-jewellery-tableware', name: 'Giftware, Jewellery & Tableware')
Sector.create(slug: 'household-goods-furniture-furnishings', name: 'Household Goods, Furniture & Furnishings')
Sector.create(slug: 'leisure-tourism', name: 'Leisure & Tourism')
Sector.create(slug: 'metallurgical-process-plant', name: 'Metallurgical Process Plant')
Sector.create(slug: 'metals-minerals-materials', name: 'Metals, Minerals & Materials')
Sector.create(slug: 'oil-gas', name: 'Oil & Gas')
Sector.create(slug: 'ports-logistics', name: 'Ports & Logistics')
Sector.create(slug: 'power', name: 'Power')
Sector.create(slug: 'renewable-energy', name: 'Renewable Energy')
Sector.create(slug: 'textiles-interior-textiles-carpets', name: 'Textiles, Interior Textiles & Carpets')
Sector.create(slug: 'technology-smart-cities', name: 'Technology and smart cities')

Sector.find_by(slug: 'technology-smart-cities').try(:update, featured: true, featured_order: 1)
Sector.find_by(slug: 'education-training').try(:update, featured: true, featured_order: 2)
Sector.find_by(slug: 'food-and-drink').try(:update, featured: true, featured_order: 3)
Sector.find_by(slug: 'creative-industries').try(:update, featured: true, featured_order: 4)
Sector.find_by(slug: 'security').try(:update, featured: true, featured_order: 5)
Sector.find_by(slug: 'consumer-and-retail').try(:update, featured: true, featured_order: 6)

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

Country.where(slug:'afghanistan').first.update(iso_code: 'AF')
Country.where(slug:'albania').first.update(iso_code: 'AL')
Country.where(slug:'algeria').first.update(iso_code: 'DZ')
Country.where(slug:'andorra').first.update(iso_code: 'AD')
Country.where(slug:'angola').first.update(iso_code: 'AO')
Country.where(slug:'antigua-and-barbuda').first.update(iso_code: 'AG')
Country.where(slug:'argentina').first.update(iso_code: 'AR')
Country.where(slug:'armenia').first.update(iso_code: 'AM')
Country.where(slug:'australia').first.update(iso_code: 'AU')
Country.where(slug:'austria').first.update(iso_code: 'AT')
Country.where(slug:'azerbaijan').first.update(iso_code: 'AZ')
Country.where(slug:'bahrain').first.update(iso_code: 'BH')
Country.where(slug:'bangladesh').first.update(iso_code: 'BD')
Country.where(slug:'barbados').first.update(iso_code: 'BB')
Country.where(slug:'belarus').first.update(iso_code: 'BY')
Country.where(slug:'belgium').first.update(iso_code: 'BE')
Country.where(slug:'belize').first.update(iso_code: 'BZ')
Country.where(slug:'benin').first.update(iso_code: 'BJ')
Country.where(slug:'bhutan').first.update(iso_code: 'BT')
Country.where(slug:'bolivia').first.update(iso_code: 'BO')
Country.where(slug:'bosnia-and-herzegovina').first.update(iso_code: 'BA')
Country.where(slug:'botswana').first.update(iso_code: 'BW')
Country.where(slug:'brazil').first.update(iso_code: 'BR')
Country.where(slug:'british-virgin-islands').first.update(iso_code: 'VG')
Country.where(slug:'brunei').first.update(iso_code: 'BN')
Country.where(slug:'bulgaria').first.update(iso_code: 'BG')
Country.where(slug:'burkina-faso').first.update(iso_code: 'BF')
Country.where(slug:'burundi').first.update(iso_code: 'BI')
Country.where(slug:'cambodia').first.update(iso_code: 'KH')
Country.where(slug:'cameroon').first.update(iso_code: 'CM')
Country.where(slug:'canada').first.update(iso_code: 'CA')
Country.where(slug:'cape-verde').first.update(iso_code: 'CV')
Country.where(slug:'central-african-republic').first.update(iso_code: 'CF')
Country.where(slug:'chad').first.update(iso_code: 'TD')
Country.where(slug:'chile').first.update(iso_code: 'CL')
Country.where(slug:'china').first.update(iso_code: 'CN')
Country.where(slug:'colombia').first.update(iso_code: 'CO')
Country.where(slug:'comoros').first.update(iso_code: 'KM')
Country.where(slug:'congo').first.update(iso_code: 'CG')
Country.where(slug:'congo-democratic-republic').first.update(iso_code: 'CD')
Country.where(slug:'costa-rica').first.update(iso_code: 'CR')
Country.where(slug:'croatia').first.update(iso_code: 'HR')
Country.where(slug:'cuba').first.update(iso_code: 'CU')
Country.where(slug:'cyprus').first.update(iso_code: 'CY')
Country.where(slug:'czechia').first.update(iso_code: 'CZ')
Country.where(slug:'denmark').first.update(iso_code: 'DK')
Country.where(slug:'dit-hq').first.update(iso_code: 'GB')
Country.where(slug:'djibouti').first.update(iso_code: 'DJ')
Country.where(slug:'dominica').first.update(iso_code: 'DM')
Country.where(slug:'dominican-republic').first.update(iso_code: 'DO')
Country.where(slug:'dso-hq').first.update(iso_code: 'GB')
Country.where(slug:'east-timor').first.update(iso_code: 'TL')
Country.where(slug:'ecuador').first.update(iso_code: 'EC')
Country.where(slug:'egypt').first.update(iso_code: 'EG')
Country.where(slug:'el-salvador').first.update(iso_code: 'SV')
Country.where(slug:'equatorial-guinea').first.update(iso_code: 'GQ')
Country.where(slug:'eritrea').first.update(iso_code: 'ER')
Country.where(slug:'estonia').first.update(iso_code: 'EE')
Country.where(slug:'eswatini').first.update(iso_code: 'SZ')
Country.where(slug:'ethiopia').first.update(iso_code: 'ET')
Country.where(slug:'fiji').first.update(iso_code: 'FJ')
Country.where(slug:'finland').first.update(iso_code: 'FI')
Country.where(slug:'france').first.update(iso_code: 'FR')
Country.where(slug:'gabon').first.update(iso_code: 'GA')
Country.where(slug:'georgia').first.update(iso_code: 'GE')
Country.where(slug:'germany').first.update(iso_code: 'DE')
Country.where(slug:'ghana').first.update(iso_code: 'GH')
Country.where(slug:'greece').first.update(iso_code: 'GR')
Country.where(slug:'grenada').first.update(iso_code: 'GD')
Country.where(slug:'guatemala').first.update(iso_code: 'GT')
Country.where(slug:'guinea').first.update(iso_code: 'GN')
Country.where(slug:'guinea-bissau').first.update(iso_code: 'GW')
Country.where(slug:'guyana').first.update(iso_code: 'GY')
Country.where(slug:'haiti').first.update(iso_code: 'HT')
Country.where(slug:'honduras').first.update(iso_code: 'HN')
Country.where(slug:'hong-kong').first.update(iso_code: 'HK')
Country.where(slug:'hungary').first.update(iso_code: 'HU')
Country.where(slug:'iceland').first.update(iso_code: 'IS')
Country.where(slug:'india').first.update(iso_code: 'IN')
Country.where(slug:'indonesia').first.update(iso_code: 'ID')
Country.where(slug:'iran').first.update(iso_code: 'IR')
Country.where(slug:'iraq').first.update(iso_code: 'IQ')
Country.where(slug:'ireland').first.update(iso_code: 'IE')
Country.where(slug:'israel').first.update(iso_code: 'IL')
Country.where(slug:'italy').first.update(iso_code: 'IT')
Country.where(slug:'ivory-coast').first.update(iso_code: 'CI')
Country.where(slug:'jamaica').first.update(iso_code: 'JM')
Country.where(slug:'japan').first.update(iso_code: 'JP')
Country.where(slug:'jordan').first.update(iso_code: 'JO')
Country.where(slug:'kazakhstan').first.update(iso_code: 'KZ')
Country.where(slug:'kenya').first.update(iso_code: 'KE')
Country.where(slug:'kiribati').first.update(iso_code: 'KI')
Country.where(slug:'kosovo').first.update(iso_code: 'XK')
Country.where(slug:'kuwait').first.update(iso_code: 'KW')
Country.where(slug:'kyrgyzstan').first.update(iso_code: 'KG')
Country.where(slug:'laos').first.update(iso_code: 'LA')
Country.where(slug:'latvia').first.update(iso_code: 'LV')
Country.where(slug:'lebanon').first.update(iso_code: 'LB')
Country.where(slug:'lesotho').first.update(iso_code: 'LS')
Country.where(slug:'liberia').first.update(iso_code: 'LR')
Country.where(slug:'libya').first.update(iso_code: 'LY')
Country.where(slug:'liechtenstein').first.update(iso_code: 'LI')
Country.where(slug:'lithuania').first.update(iso_code: 'LT')
Country.where(slug:'luxembourg').first.update(iso_code: 'LU')
Country.where(slug:'macao').first.update(iso_code: 'MO')
Country.where(slug:'madagascar').first.update(iso_code: 'MG')
Country.where(slug:'malawi').first.update(iso_code: 'MW')
Country.where(slug:'malaysia').first.update(iso_code: 'MY')
Country.where(slug:'maldives').first.update(iso_code: 'MV')
Country.where(slug:'mali').first.update(iso_code: 'ML')
Country.where(slug:'malta').first.update(iso_code: 'MT')
Country.where(slug:'marshall-islands').first.update(iso_code: 'MH')
Country.where(slug:'mauritania').first.update(iso_code: 'MR')
Country.where(slug:'mauritius').first.update(iso_code: 'MU')
Country.where(slug:'mexico').first.update(iso_code: 'MX')
Country.where(slug:'micronesia').first.update(iso_code: 'FM')
Country.where(slug:'moldova').first.update(iso_code: 'MD')
Country.where(slug:'monaco').first.update(iso_code: 'MC')
Country.where(slug:'mongolia').first.update(iso_code: 'MN')
Country.where(slug:'montenegro').first.update(iso_code: 'ME')
Country.where(slug:'morocco').first.update(iso_code: 'MA')
Country.where(slug:'mozambique').first.update(iso_code: 'MZ')
Country.where(slug:'myanmar').first.update(iso_code: 'MM')
Country.where(slug:'namibia').first.update(iso_code: 'NA')
Country.where(slug:'nauru').first.update(iso_code: 'NR')
Country.where(slug:'nepal').first.update(iso_code: 'NP')
Country.where(slug:'netherlands').first.update(iso_code: 'NL')
Country.where(slug:'new-zealand').first.update(iso_code: 'NZ')
Country.where(slug:'nicaragua').first.update(iso_code: 'NI')
Country.where(slug:'niger').first.update(iso_code: 'NE')
Country.where(slug:'nigeria').first.update(iso_code: 'NG')
Country.where(slug:'north-korea').first.update(iso_code: 'KP')
Country.where(slug:'north-macedonia').first.update(iso_code: 'MK')
Country.where(slug:'norway').first.update(iso_code: 'NO')
Country.where(slug:'oman').first.update(iso_code: 'OM')
Country.where(slug:'pakistan').first.update(iso_code: 'PK')
Country.where(slug:'palau').first.update(iso_code: 'PW')
Country.where(slug:'palestinian-territories').first.update(iso_code: 'PS')
Country.where(slug:'panama').first.update(iso_code: 'PA')
Country.where(slug:'papua-new-guinea').first.update(iso_code: 'PG')
Country.where(slug:'paraguay').first.update(iso_code: 'PY')
Country.where(slug:'peru').first.update(iso_code: 'PE')
Country.where(slug:'poland').first.update(iso_code: 'PL')
Country.where(slug:'portugal').first.update(iso_code: 'PT')
Country.where(slug:'qatar').first.update(iso_code: 'QA')
Country.where(slug:'romania').first.update(iso_code: 'RO')
Country.where(slug:'russia').first.update(iso_code: 'RU')
Country.where(slug:'rwanda').first.update(iso_code: 'RW')
Country.where(slug:'samoa').first.update(iso_code: 'WS')
Country.where(slug:'san-marino').first.update(iso_code: 'SM')
Country.where(slug:'sao-tome-and-principe').first.update(iso_code: 'ST')
Country.where(slug:'saudi-arabia').first.update(iso_code: 'SA')
Country.where(slug:'senegal').first.update(iso_code: 'SN')
Country.where(slug:'serbia').first.update(iso_code: 'RS')
Country.where(slug:'seychelles').first.update(iso_code: 'SC')
Country.where(slug:'sierra-leone').first.update(iso_code: 'SL')
Country.where(slug:'singapore').first.update(iso_code: 'SG')
Country.where(slug:'slovakia').first.update(iso_code: 'SK')
Country.where(slug:'slovenia').first.update(iso_code: 'SI')
Country.where(slug:'solomen-islands').first.update(iso_code: 'SB')
Country.where(slug:'somalia').first.update(iso_code: 'SO')
Country.where(slug:'south-africa').first.update(iso_code: 'ZA')
Country.where(slug:'south-korea').first.update(iso_code: 'KR')
Country.where(slug:'south-sudan').first.update(iso_code: 'SS')
Country.where(slug:'spain').first.update(iso_code: 'ES')
Country.where(slug:'sri-lanka').first.update(iso_code: 'LK')
Country.where(slug:'st-kitts-and-nevis').first.update(iso_code: 'KN')
Country.where(slug:'st-lucia').first.update(iso_code: 'LC')
Country.where(slug:'st-vincent').first.update(iso_code: 'VC')
Country.where(slug:'sudan').first.update(iso_code: 'SD')
Country.where(slug:'suriname').first.update(iso_code: 'SR')
Country.where(slug:'sweden').first.update(iso_code: 'SE')
Country.where(slug:'switzerland').first.update(iso_code: 'CH')
Country.where(slug:'syria').first.update(iso_code: 'SY')
Country.where(slug:'taiwan').first.update(iso_code: 'TW')
Country.where(slug:'tajikistan').first.update(iso_code: 'TJ')
Country.where(slug:'tanzania').first.update(iso_code: 'TZ')
Country.where(slug:'thailand').first.update(iso_code: 'TH')
Country.where(slug:'the-bahamas').first.update(iso_code: 'BS')
Country.where(slug:'the-gambia').first.update(iso_code: 'GM')
Country.where(slug:'the-philippines').first.update(iso_code: 'PH')
Country.where(slug:'the-united-arab-emirates').first.update(iso_code: 'AE')
Country.where(slug:'the-usa').first.update(iso_code: 'US')
Country.where(slug:'togo').first.update(iso_code: 'TG')
Country.where(slug:'tonga').first.update(iso_code: 'TO')
Country.where(slug:'trinidad-and-tobago').first.update(iso_code: 'TT')
Country.where(slug:'tunisia').first.update(iso_code: 'TN')
Country.where(slug:'turkey').first.update(iso_code: 'TR')
Country.where(slug:'turkmenistan').first.update(iso_code: 'TM')
Country.where(slug:'tuvalu').first.update(iso_code: 'TV')
Country.where(slug:'uganda').first.update(iso_code: 'UG')
Country.where(slug:'ukraine').first.update(iso_code: 'UA')
Country.where(slug:'ukrep').first.update( iso_code: 'N/A')
Country.where(slug:'uruguay').first.update(iso_code: 'UY')
Country.where(slug:'uzbekistan').first.update(iso_code: 'UZ')
Country.where(slug:'vanuatu').first.update(iso_code: 'VU')
Country.where(slug:'vatican-city').first.update(iso_code: 'VA')
Country.where(slug:'venezuela').first.update(iso_code: 'VE')
Country.where(slug:'vietnam').first.update(iso_code: 'VN')
Country.where(slug:'yemen').first.update(iso_code: 'YE')
Country.where(slug:'zambia').first.update(iso_code: 'ZM')
Country.where(slug:'zimbabwe').first.update(iso_code: 'ZW')

