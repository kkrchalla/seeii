#!/usr/bin/perl
#$rcs = ' $Id: search,v 1.0 2004/03/30 00:00:00 Exp $ ' ;

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

$|=1;    # autoflush
open(STDSAVE, ">&STDOUT");
  use Fcntl;
  use DBI;
  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my $sth;
  my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;

#  my @query_array = qw(india bharat hindustan india+states india+languages india+history india+city india+river india+food india+recipe india+politics india+movies india+music india+arts india+culture india+songs hindu bay+of+bengal arabian+sea indian+ocean india+lakes india+dams india+reservoirs india+roads india+bridges india+highways india+trains india+railways india+transportation india+airports india+airlines india+pilgrim india+gods india+mythology india+geography india+mountains
#india+valleys india+prime+minister india+chief+minister india+governer india+president india+mla india+mp india+parliament india+rajyasabha india+loksabha india+actors india+televison india+singers india+musicians india+monuments india+temples india+games india+festivals india+animals india+birds india+insects india+reptiles india+amphibians india+plants india+fruits india+flowers india+roots india+trees india+leaves india+medicines india+ayurved india+vedas india+homeopathy india+magazines india+news
#india+newspapers india+maps india+seasons india+inventors india+univercity india+college india+poets india+novels india+poems india+novelists india+prose india+ramayana india+mahabharat india+products india+disasters india+phone+cards india+stocks india+economy india+currency india+realestate india+cooking india+blog india+metals india+ore india+military india+historic+places india+navy india+army india+airforce india+archealogy india+diseases india+infection india+adult india+matrimony india+travel
#india+islands india+sex india+history india+men india+women india+children india+boys india+girls air+india air+india+express air+ticket+to+india ancient+india bangalore+india bank+of+india busty+india delhi+india+new+protest embassy+india+san+francisco gay+india gift+to+india goa+india google+india government+of+india history+of+india income+tax+india india+abroad india+arie india+budget india+business india+calling+card india+chat india+china india+country+code india+cricket india+fashion india+flag
#india+fm india+forum india+forum india+hotel india+name india+newspaper india+nude india+pakistan india+pakistan+cricket india+palace india+passion india+phone+card india+photo india+picture india+population india+porn india+program india+radio india+restaurant india+shopping india+time india+today india+tour india+tourism india+visa india+vs+pakistan india+woman india+xxx institute+of+chartered+accountant+of+india jobs+india la+india lic+of+india life+insurance+corporation+of+india map+of+india
#miss+india msn+india music+india+online outsourcing+india passage+to+india porn+star+india reliance+india religion+of+india reserve+bank+of+india search+engine+optimization+india seo+india sexy+india star+of+india state+bank+of+india taj+mahal+india times+of+india trip+to+india web+design+india yahoo+india bharat+matrimony bharat+matrimonial bharat+rakshak bharat bharat+petroleum bharat+sanchar+nigam bharat+sanchar bharat+forge bharat+petroleum+corporation bharat+greeting bharat+bazaar
#nav+bharat+times bharat+mata bharat+electronics bharat+mission+uday bharat+gas bharat+natyam bharat+heavy+electricals+limited bharat+ratna bharat+shah bharat+india+matrimony bharat+sevashram+sangha bharat+patel bharat+scout+and+guide bharat+heavy+electricals bharat+uday bharat+nirman bharat+sevak+samaj bharat+soka+gakkai bharat+army bharat+overseas+bank bharat+bhushan toyota+bharat bharat+bijlee bharat+earth+mover bharat+darshan bharat+dynamics award+bharat+jyoti bharat+biotech bharat+scout
#bharat+shell bharat+sahni bharat+thakur bharat+bijlee bharat+coach nav+bharat bharat+hotel bharat+ek+khoj bharat+mata+painting bharat+chat bharat+online bharat+textile jai+bharat+maruti bharat+sex achankovil+river adyar+river ahar+river aner+river alaknanda+river amaravati+river arkavathy+river ban+ganga+river badiya+river banas+river bavanthadi+river beas+river berach+river betwa+river bhagirathi+river bharathapuzha+river bhavani+river bhima+river brahmani+river brahmaputra+river budhi+gandak
#chalakkudy+river chaliyar+river chambal+river chenab+river cooum daman+ganga+river damodar+river dhasan+river dudhana+river ganges+river gambhir+river gandak gayathripuzha ghaggar+river ghaghara+river girija+river girna+river godavari+river gomti+river halali+river haora+river hoogli+river indus+river indravati+river jaldhaka jhelum+river kabini+river kali+sindh+river kaliasote+river kalpathipuzha kanhan+river kannadipuzha karnaphuli+river kaveri+river kelna+river khadakpurna+river kodoor+river
#koel+river kolab+river kollidam+river kosi+river koyna+river krishna+river lachen+river lachung+river luni+river mahanadi+river mahananda+river mahakali+river mahi+river mandovi+river meenachil+river meghna+river mithi+river mula+river musi+river mutha+river narmada+river nethravathi+river palar+river pahuj+river panjnad+river panzara+river 

  my @query_array = qw(parbati+river payaswini pench+river penner+river periyar+river ponnaiyar+river pranhita+river purna+river rangeet+river ravi+river rihand+river rupnarayan+river
sabarmati+river sankh+river sharavathi+river shipra+river sindh+river son+river south+koel+river subarnarekha+river sutlej+river surya+river tansa+river tapti+river tawa+river teesta+river thuthapuzha tunga+river tungabhadra+river vaan+river vaigai+river vashishti+river vedavathi+river ulhas+river wainganga+river wagh+river wardha+river west+banas+river yamuna+river zuari+river 24+parganas+north 24+parganas+south adilabad agartala agra ahmedabad ahmednagar ahwa aizawl ajmer akbarpur akola alappuzha
alibag aligarh alipore allahabad almora along alwar ambala ambassa ambedkar+nagar ambikapur amravati amreli amritsar amroha anand anantapur anantnag andaman+and+nicobar+islands andaman+islands andhra+pradesh angul anini ara araria ariyalur arunachal+pradesh assam assamese auraiya aurangabad azamgarh badaun badgam bagalkot bageshwar baghmara baghpat bahraich balaghat baleshwar ballia balrampur balurghat banas+kantha banda bandra bangalore bangalore+rural banka bankura banswara barabanki baragarh
baramula baran barasat bardhaman bareilly baripada barmer barpeta barwani bastar basti bathinda begusarai belgaum bellary bengali berhampore bettiah betul bhabua bhadohi bhadrak bhagalpur bhandara bharatpur bharuch bhavnagar bhawanipatna bhilwara bhind bhiwani bhojpur bhopal bhubaneswar bhuj bid bidar bihar bihar+sharif bijapur bijnor bikaner bilaspur birbhum bishnupur bokaro bolangir bombay bomdila bongaigaon boudh bulandshahr buldhana bundi buxar cachar calcutta car+nicobar chabasa chamba chamoli
champawat champhai chamrajnagar chandauli chandel chandigarh chandrapur changlang chatra chennai chhapra chhatarpur chhatrapur chhattisgarh chhindwara chikmagalur chinsurah chitradurga chitrakoot chitrakootdham chittoor chittorgarh churachandpur churu coimbatore cuddalore cuddapah cuttack dadra+and+nagar+haveli dahod dakshin+dinajpur dakshina+kannada daltonganj daman daman+and+diu damoh dantewada daporijo darbhanga darjeeling darrang datia dausa davanagere dehradun delhi deogarh deoghar deoria dewas
dhalai dhamtari dhanbad dhar dharamasala dharmapuri dharwad dhemaji dhenkanal dholpur dhubri dhule dibang+valley dibrugarh dimapur dindigul dindori diphu dispur diu doda dumka dungarpur durg east+garo+hills east+godavari east+imphal east+kameng east+khasi+hills east+nimar east+siang east+sikkim eluru english+bazar ernakulam erode etah etawah faizabad faridabad faridkot farrukhabad fatehabad fatehgarh fatehgarh+sahib fatehpur firozabad firozpur gadag gadchiroli gajapati gandhinagar ganganagar gangtok
ganjam garhwa gautam+buddha+nagar gaya gezing ghaziabad ghazipur giridih goa goalpara godda golaghat gonda gondiya gopalganj gorakhpur gujarat gujarati gulbarga gumla guna guntur gurdaspur gurgaon guwahati gwalior haflong hailakandi hajipur hamirpur hanumangarh harda hardoi haridwar haryana hassan hathras haveri hazaribagh himachal+pradesh hindi hingoli hissar hooghly hoshangabad hoshiarpur howrah hyderabad idukki imphal indore itanagar jabalpur jagatsinghpur jagdalpur jaintia+hills jaipur jaisalmer
jajpur jalandhar jalaun jalgaon jalna jalore jalpaiguri jammu jammu+and+kashmir jamnagar jamshedpur jamui janjgir janjgir-champa jashpur jaunpur jehanabad jhabua jhajjar jhalawar jhansi jharkhand jharsuguda jhunjhunun jind jodhpur jorhat jowal junagadh jyotiba+phule+nagar kachchh kailasahar kaimur kaithal kakinada kalahandi kalpetta kamrup kancheepuram kandhamal kangra kanker kannada kannauj kannur kanpur kanpur+dehat kanyakumari kapurthala karaikal karauli karbi+anglong kargil karimganj karimnagar
karnal karnataka karur karwar kasargod kashmiri kathua katihar katni kaushambi kavaratti kawardha kendrapara keonjhar kerala keylong khagaria khalilabad khammam khandwa khargone kheda kheri khonsa khordha kinnaur kishanganj koch+bihar kochi kodagu koderma kohima kokrajhar kolar kolasib kolhapur kolkata kollam konkani koppal koraput korba koriya kota kottayam kozhikode krishna krishnanagar kulu kupwara kurnool kurukshetra kushinagar lahaul+and+spiti lakhimpur lakhimpur+kheri lakhisarai lakshadweep
lalitpur lamphelpat latur lawngtlai leh lohardaga lohit lower+subansiri lucknow ludhiana lunglei machilipatnam madhepura madhubani madhya+pradesh madikeri madras madurai maharajganj maharashtra mahasamund mahbubnagar mahe mahendragarh mahesana mahoba mainpuri malappuram malayalam malda malkangiri mamit mandi mandla mandsaur mandya mangaldai mangalore mangan manipur mansa marathi margao marigaon mathura mau maunathbhanjan mayurbhanj medak meerut meghalaya midnapore mirzapur mizoram moga mokokchung
mon moradabad morena motihari muktsar mumbai mumbai+city mumbai+suburban munger murshidabad muzaffarnagar muzaffarpur mysore nabarangpur nadia nagaland nagaon nagapattinam nagaur nagercoil nagpur nahan nainital nalanda nalbari nalgonda namakkal namchi nanded nandurbar narmada narnaul narsinghpur nashik navgarh navsari nawada nawan+shehar nayagarh neemuch nellore new+tehri nicobar+islands nilgiris nizamabad noida nongpoh nongstoin north+cachar+hills north+goa north+sikkim north+tripura nuapada
ongole orai oras orissa oriya osmanabad padarauna painaw pakur palakkad palamu pali panaji panch+mahals panchkula panikoili panipat panna papum+pare paralakhemundi parbhani pashchim+champaran pashchim+singhbhum pasighat patan pathanamthitta patiala patna pauri pauri+garhwal perambalur phek phulbani pilibhit pithoragarh pondicherry poonch porbandar porompat port+blair prakasam pratapgarh pudukkottai pulwama pune punjab punjabi purba+champaran purba+singhbhum puri purnia purulia rae+bareli raichur
raigarh raigunj raipur raisen rajasthan rajauri rajgarh rajkot rajnandgaon rajpipla rajsamand ramanathapuram rampur ranchi rangareddi ratlam ratnagiri rayagada reckong+peo rewa rewari ri-bhoi robertsganj rohtak rohtas rudra+prayag rudrapur rupnagar sabar+kantha sagar saharanpur saharsa sahibganj saiha salem samastipur sambalpur sangareddi sangli sangrur sant+kabir+nagar sant+ravi+das+nagar saran satara satna sawai+madhopur sehore senapati seoni seppa serchhip shahdol shahjahanpur shajapur
sheikhpura sheohar sheopur shillong shimla shimoga shivpuri shravasti sibsagar siddharth+nagar sidhi sikar sikkim silchar silvassa sindhi sindhudurg sirmaur sirohi sirsa sitamarhi sitapur sivaganga siwan solan solapur sonbhadra sonepat sonepur sonitpur south+garo+hills south+goa south+sikkim south+tripura srikakulam srinagar srinagar,+jammu sultanpur sundargarh supaul surat surendranagar surguja suri susaram tamenglong tamil tamil+nadu tawang tehri+garhwal telugu tezu thane thanjavur the+dangs
theni thiruvallur thiruvananthapuram thiruvarur thoothukudi thoubal thrissur tikamgarh tinsukia tirap tiruchirappalli tirunelveli tiruvannamalai tonk tripura tuensang tumkur tura udaipur udhagamandalam udham+singh+nagar udhampur udupi ujjain ukhrul umaria una unnao upper+siang upper+subansiri urdu uttar+dinajpur uttar+pradesh uttara+kannada uttaranchal uttarkashi vadodara vaishali valsad varanasi vellore vidisha villupuram virudhunagar vishakhapatnam vizianagaram warangal wardha washim wayanad
west+bengal west+garo+hills west+godavari west+imphal west+kameng west+khasi+hills west+nimar west+siang west+sikkim west+tripura williamnagar wokha yamuna+nagar yanam yavatmal yingkiong yupia ziro zunheboto);


  $insert  = $dbh->prepare_cached("INSERT INTO INDEX_DB.URL_LIST_TAB  VALUES (?, ?, ?)");
  $select  = $dbh->prepare_cached("SELECT 1 FROM INDEX_DB.URL_LIST_TAB WHERE URL = ?");

  my $LOG_FILE = 'c:/seeii/sortlog.txt';

  open(STDOUT, ">>$LOG_FILE") or die "Cannot open LOGFILE for WRITING: $!";
  print "STARTING URLSORTER \n";

  my $count = 0;
  my $querycount = 0;
  print " count = $count \n";
  foreach my $query (@query_array) {
    my $URL_FILE = 'c:/seeii/scannedurls/'.$query.'.txt';

    if (-e $URL_FILE) {

      $querycount = 0;
      open(URLFLE, $URL_FILE) or die "Cannot open urlfile '$URL_FILE' for reading: $!";

      while (<URLFLE>) {
        chomp;
        $_ =~ s/\r//g; # get rid of carriage returns
        $url = $_;
        my @row_url = ();
        $select->execute($url);
        @row_url = $select->fetchrow_array;
        $select->finish;
        if (! @row_url) {
           $success = $insert->execute($url, 'Y', 0);
           if ($success != 1) { print " error for $url \n";}
           $querycount++;
        }
      }
      close(URLFLE);
      print LOGFLE $query."\n";
      print " $query processed $querycount\n";
      print STDSAVE " $query processed $querycount\n";
    } else {
      print " $query is not found \n";
      print STDSAVE " $query is not found \n";
    }
    $count = $count + $querycount;
  }
  print " count = $count \n";
  print STDSAVE " count = $count \n";
  $dbh->disconnect;
  flock(LOGFLE, LOCK_UN);
  close(LOGFLE);

exit;