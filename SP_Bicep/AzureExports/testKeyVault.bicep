param keyVaultName string
param location string
param certificateName string
@allowed([
  'dev'
  'prd'
])
param environment array

@secure()
param certificatePassword string

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'myFunctionApp'
  location: location
  properties: {
    serverFarmId: 'myAppServicePlanId'
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=myStorageAccount;AccountKey=myStorageAccountKey;EndpointSuffix=core.windows.net'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'KeyVaultName'
          value: keyVaultName
        }
        {
          name: 'CertificateName'
          value: certificateName
        }
      ]
    }
  }    
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: functionApp.properties.identity.principalId
        permissions: {
          keys: ['get', 'create', 'delete', 'list', 'update', 'import', 'backup', 'restore', 'recover', 'purge']
          secrets: ['get', 'list', 'set', 'delete', 'backup', 'restore', 'recover', 'purge']
          certificates: ['get', 'list', 'delete', 'create', 'import', 'update', 'managecontacts', 'getissuers', 'listissuers', 'setissuers', 'deleteissuers', 'manageissuers', 'recover', 'purge']
        }      
      }
    ]
    enabledForDeployment: true
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
  }
}

resource certificate 'Microsoft.KeyVault/vaults/certificates@2021-06-01-preview' = {
  parent: keyVault
  name: certificateName
  properties: {
    certificateAttributes: {
      enabled: true
    }
    secretProperties: {
      contentType: 'application/x-pkcs12'
      value: '舰耊Ă〃ંؼ⨉䢆čć芠ⴊ舄⤊舰┊舰؆आ蘪虈෷܁ꀁւӷւンւワւ۫⨋䢆č਌ȁ芠︄舰宅ᰰਆ蘪虈෷ఁ́ะࠄ醗篩ᢺ�Ȃ퀇舄�䓖淴ࢆ塊ￍ糓䳛㡔訶ｦ宂⎴桗紾㾚졡釓购뀄ধ쳨㸕䟛ﯲꨰ偍८넿鰌⺁䐛䛃稅Ջᰦ怆鼋쥇�僬懞᯼䝡簦㩏ꔋ嗨㐆훛⺫�竀헴쯕Ⳛ즛ﻄ莏林鷷鯰∭閕ᛡ殛ᅂ뵐嚱釛鲜㮞삆낖젽衳纘蓘떺朂㙂䐴綿꠾኎倔莝�罰�皇⏆糧쎗懲參퐖ᕍ䮨氅অ鱨좺㍋늖凴멀힑仐篕ퟋ觉킹츕蓐ᮕ䠖⩑�蠭�髗嫜듉ߡ좇欸糇螙霽鎪Ἆ踚﹇ט窱␳뙦뿉좿�☔짢䯾䈦膧✖൯ꉎ㬥¾િ鋯ዽ䡺ꨛ㞓広◒꽑器휣콴�բ枑⫚뒃ꃧ忙⚄凨ퟡ堀旸왵昇鎕໾錵뿂踷ꨍ㏁蔓튁療秌通浚❢贆躅퍼ꅍ椼歛僣瞂당췅_䩁荌鯳㈹褅읞驸ທ쫺ਕ洭ⴠ⇪꒰旓鴤毺笳ك⬅報뤷ᗄ틊�샻낢鞞펹덻鑙튍Ꮹ啌ㆤ뇌Қ쯮游ₗ繃祒킏�ﴞ麥惻鶧潃䱾⡘嘽酄홲⸐ꃕ蠼첟ﾯꖛ촛⇆䉴幇謠㐪૽웂隭뀁㉀৅⢻骤譗븽뗕㜹놥鶝쳵ଶ꺸ბ⸊ᛋ㻦犒孭뾖괧濢基䤂䄶䞶㟣垸舚춹䛱╾㎟㉸�ꮯ슋䙴ﺥᛶ㔳搎㛚뙓勉�叺Ῐ泂厞醟惇㾴괘蔙薛쌽ꄿ襹ꂜ넯ⵧ酏੏梺ꆌ敓눙�ߧ酟ᡓ�쑊→ఔꔭ慦츮墷쇛Ỗ캕殫鸭铪㷛꣹ퟢ傑袢֝�狶婎⎐搔Ĭ쓭䙳㠀濊뚡鏇靎牗㴐붻魻ﾶ醧魕ꋉᡣ㎳쌬傇鴧꜍ࠨ萇聨컣⿶䫊미꡺䖙떗愂웋ቜЂ㔓剔橎陟⧺虁묝쀠㱕۱逈턪㷍ꄦ䤭㳑裝䙒鯥麫어전찯慯駓ભ[ὐ쑢䈧▩쇄ῆ겅텖�ԝᙚ⅟女蒄࿩⧭浲಺񈰫␀�硻♈ඟ퉢㿧銇曥⪾㫽퐂䪜鱉臭㯪旄飷㻫ᝥᄠꐱ䬉隒㔠甤㩻奐壝ଲ┤䮍뇏镺邉흭㲹瀚籏�쥈ゑ呔봈臸佳⃞Б跾䓆鲏윛ⳋ嵉馻긼譿飙찑놽⭋ᦓᱵ넖楈㕏ᅍ톪縰�㸺뾎⻭홃轶䐮술苖薮碌䄿擨州颇䢒菚禃庶뗩�礪ਤ휓뵑㹺濨蔪쎜ꪉⳎⓂꐴ㽊佂䃟甼脱ベؓ⨉䢆čᔉرЄ 崰आ蘪虈෷ँㄔṐNte-72c4f6a2-677e-4e95-91a7-60204508fa5つ٣⬉ĆĄ㞂đ嘱吞䴀椀挀爀漀猀漀昀琀 䈀愀猀攀 䌀爀礀瀀琀漀最爀愀瀀栀椀挀 倀爀漀瘀椀搀攀爀 瘀㄀⸀　舰ᜄआ蘪虈෷܁ꀆ҂〈҂Ȅ舰ﴃआ蘪虈෷܁、؜⨊䢆čČ〃Ў谈行덭�˰܂胐΂䫐蘀栈烤旚Ủ슜�༩兙떡ꛦᦟᑳ⎶ʰ஍ᵫၢ쬏筂魙዁萯㴳ᴜ蕘ጙ⾫Ȭ葮豜蹏⾨쓷祲捂䳹鲪톈짼ꪣ㠍ᯍ㇝㊐圛珧᠂搵㗏햸詁慇界ﹾ櫑ㄪǷ䈰过㉨�ᭉ؞巂㱦苝ꟿ㬴駪琨寘ꫣ濸ﵘ橣᫒㗬鹳愁讘꺂봋ڙ廊⹄c㟲⸖璳뉭݄긲⡿൷鶥늱者輍ꔛ馠滭页擣䥏쿸롡웬湻몚ジ曆ꦊ懿䠫Ⲷ䒠偺銞奜렷蠟㳼挐度ῡ↚떴吞潒Ừ뎾⛾୔ᖞﾦ�ȋיִ垶䀲㤎껤퀣�⶟�ઠ徚䔣츧Ⴃ䉐淄멵苄뇽෡哩୅笊爴쬁㮮睡隽됆�ꔊ襞깍覞᪟뙑Ꟈ�딩熮墆ᅽ漚ඩໄ㲁ꘫ㾅赟䋁ꩱ檄깿騹뀉铆턼颋踘泷᪊ꄰ줿ꖨ띪궰섍뒘챑螭☰뾷ॢ굠ਸ퓭䇽䴐橝祁瑼䩐삄쩨䄍μ踳麴䥷峺艏㱐탖䭄퍨줉귵ᨅ㖈೔픨⁇빠췐�ꨢ趭�쟒홑回㢌⛇聭퍛ᵷ絒梕洍斶篱왌�埲ꭗᥛ྄ꂵ孨ガ榼暈䲝録䎞䑃㍗葖漵걆凛ᓛ컀뵲㞭䭽೉䷚뼚☌⎉螋䦳�锥螁ဉ⇇㸔€逨꿶㱎풃㥘დᲛ቞葾㎹搰䊇ҧኩ㨘䄊밷煯ዬ륹뱗耋橌奞ᇦĭ㍼혺Ⲍ곐㢨᠚ꫮ昧锏諾榭걽䓬顇�饠闷㟪ӯ佃䣪቟효虁᱃딆⡳逻�䢋믈ê䈫᭹锓鈍埘Ǌ藮니ḍູ℔为耋₩俍弰�斏䞧ẝ⁉道ꉦ砈裎흽ᦽ菃阕籈﷤槁䗯⍞栂᯺鍍Ⰿⴭ鐊㑞尪㯕慧洠琲៷簍볙뿻嶳ힵᾋయ馕嶅潮꤇䮣ᤲ䢉滖ϊ娐ꔂ潚ѢĹ굠韬Ř搠굜ỽṸዯ㪏⊎ά⩃￨ᩥ묳ဓぴ〻〟؇⬅̎ᨂᐄ૑﮺힘릯꒝嚊怼娉荻潴ᐄ἞劉㨿朅ᛍ灦䪔쐼䫺ˎȂ퀇'
      password: certificatePassword
    }
  }
}
