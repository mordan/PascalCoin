unit URandomHashTests;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, SysUtils, {$IFDEF FPC}fpcunit,testregistry,{$ELSE}TestFramework,{$ENDIF FPC}
  UUnitTests, HlpIHash;

type

  { TRandomHashTest }

  TRandomHashTest = class(TPascalCoinUnitTest)
  public type
    TTransformProc = function(const AChunk: TBytes): TBytes of object;
  private
    procedure TestSubHash(AHasher : IHash; const ATestData : array of TTestItem<Integer, String>);
    procedure TestMemTransform(ATransform : TTransformProc; const ATestData : array of TTestItem<Integer, String>);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRandomHash_Standard;
    procedure TestRandomHash;
    procedure TestSHA2_256;
    procedure TestSHA2_384;
    procedure TestSHA3_256;
    procedure TestSHA3_384;
    procedure TestSHA3_512;
    procedure TestRIPEMD160;
    procedure TestRIPEMD256;
    procedure TestRIPEMD320;
    procedure TestBLAKE2B;
    procedure TestBLAKE2S;
    procedure TestTIGER2_5_192;
    procedure TestSNEFRU_8_256;
    procedure TestGRINDAHL512;
    procedure TestHAVAL_5_256;
    procedure TestMD5;
    procedure TestRADIOGATUN32;
    procedure TestWHIRLPOOL;
    procedure TestMURMUR3_32;
    procedure TestChecksum_1;
    procedure TestChecksum_2;
    procedure MemTransform_Standard;
    procedure MemTransform1;
    procedure MemTransform2;
    procedure MemTransform3;
    procedure MemTransform4;
    procedure MemTransform5;
    procedure MemTransform6;
    procedure MemTransform7;
    procedure MemTransform8;
  end;

implementation

uses variants, UCommon, UMemory, URandomHash, HlpHashFactory, HlpBitConverter;

const

  { General purpose byte array for testing }

  DATA_BYTES : String = '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b00000000';

  { RandomHash Official Values }

  DATA_RANDOMHASH_STANDARD : array[1..3] of TTestItem<String, String> = (
    (Input: '0x0';                                         Expected: '0xee5083042dd2ae10093e2c91e4479fbcf411d991c235c11182a64185c9ed1d8c'),
    (Input: 'The quick brown fox jumps over the lazy dog'; Expected: '0x3c16f307f408053cb291d8eb4c92596ab2d98a35ecf7aac8f6b4e26cbb2b3d18'),
    (Input: '0x000102030405060708090a0b0c0d0e0f';          Expected: '0x3b2387647893bbd2bdc15d977d314add8842a92166eeb9ede8d597437567e815')
  );

  {  Hash Test Data }

  DATA_RANDOMHASH : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x15006c696e50827cc1660d0ffac51401236e5c67ea596b1f871fe3f791e21711'),
    (Input: 31;  Expected: '0x7f80d579b2d51206554f95cc1259619120fe16fb66e762bb33036f4e0b1835b5'),
    (Input: 32;  Expected: '0xfa7160eb1f99e938c5ee60e9cab6fc027f7f9e8c6c7b4df4fe12eb1906301bc5'),
    (Input: 33;  Expected: '0x29dde50ccf38dec17ef1966e1e2c98179409779857cb376d7e82d173a83d48a3'),
    (Input: 34;  Expected: '0x1b300acf63774eab276320fa563cf0d10ba197e3eae1ba3eb528a2ec435e8e29'),
    (Input: 63;  Expected: '0x6133ff338df00db1d1916a733c44559183df178812f012d5d13137e07c6cac94'),
    (Input: 64;  Expected: '0x8fb83a902db3788a2715ceec394744833bd4a214ee0af82a342be9a84a54b4d7'),
    (Input: 65;  Expected: '0xd5fce9287330af575ba6deeff0d91c7cd90c698e6dbe0601b00386d9233e447d'),
    (Input: 100; Expected: '0x5218d5cdf3d97075b44f2cb285fe43e755635eb441df296fa8bf13e1f0b2df2f'),
    (Input: 117; Expected: '0xe372c86d681a48ffca48891f807b72f6abab9863338cd65bb38b73b030249cc3'),
    (Input: 127; Expected: '0x373cc76b01659814ac95fa778eaa7f9a74f3eebb9b1e0a2ce7827a20d6d84c0a'),
    (Input: 128; Expected: '0xdc25b5daf5f42897a038d79b767ca5b30847fefb0f49d0a95821786026d220e5'),
    (Input: 129; Expected: '0xbe87202a6754b1230e5c56921b880aa27a67b1b92e5a5be60876d479f843917e'),
    (Input: 178; Expected: '0xfb328e6638fc33a6490c8caa38052aa82d094c031ddb723642cc7671f90b7838'),
    (Input: 199; Expected: '0x7728313d2b47a9ef21e19ef3ca9906f36054e69c8732cefc03851c3968840ef9'),
    (Input: 200; Expected: '0x0d609b16eb1e7d8b42df0e0c6ea474f30e65d27ebff256935088a0a6768df2b1')
  );

  DATA_SHA2_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x0fd3f87ae8963c1ac8aabc0706d2ad5a66c2d88b50f57821b864b093263a7a05'),
    (Input: 31;  Expected: '0x209ef563d4ac7d51968cced180be0145dbd4d4c9688bdbdd8fcdb171029bff35'),
    (Input: 32;  Expected: '0xa910d364190b6aed1c0a4198688a1a5ac4b37205c542d665be0f5aa558ad483e'),
    (Input: 33;  Expected: '0x8f2d5d44ca1a2f534253a600c4e95f315133f775127a11bcb22db928efbd638d'),
    (Input: 34;  Expected: '0xda8f41e9f2ac0effa4815a50f599b0791f210cb85f056672404639c960f56fe8'),
    (Input: 63;  Expected: '0xb06a88f708c40510cc132a5108c6f26a9a3f7f6d42e0143baaacaf96aec16952'),
    (Input: 64;  Expected: '0x3725408cbe6e81f8a05bd2f1b4618a356235b7262eb809608bc4e3dc38e4fa1f'),
    (Input: 65;  Expected: '0xaf29a07c4c9ca57aa087a3c6134573615ec8b54706c75361cfd23fba38d8a5d0'),
    (Input: 100; Expected: '0x30cb592bdaf02c26fcba00c055059d9c3cf74f10a7eb49e2fcd4926c86c85e00'),
    (Input: 117; Expected: '0x1e34859b3591e50f8522d707a554725591603b95725d8d16f9dc728f901091d4'),
    (Input: 127; Expected: '0x6b3e56f2349c09aa0a814a0c5a9dfb72e13b79c57d3dd5bf802ab00c5040164b'),
    (Input: 128; Expected: '0x75b01600de565f4138151f345028a91a8471385509dfe27e2d07096b4c82136b'),
    (Input: 129; Expected: '0x5536bf5cdf0739e4ff259eb79a4276a009717e371057a3b8afe4ba79a03a884a'),
    (Input: 178; Expected: '0xad69c11f5d88dc4b047174218e843fdb29dbfb8dd2697f017bc8cd98a6a7b7fd'),
    (Input: 199; Expected: '0xcafebf56cdeaec6505b97a0f52369a79fa441d4d2e5a034d16ab0df00172b907'),
    (Input: 200; Expected: '0xd20e764994f9a21ca01a3e9247bc70618f39663773c3a7a839d8a2e1072f182d')
  );

  DATA_SHA2_384 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x86b2d0189776966214f3469254c4a2e9d4fadbb81aab5d9ef8d67f085301a5128758c8f3b9b89d8d4460c684fe181a58'),
    (Input: 31;  Expected: '0xf19c9457db4e320f0a795dd911f46e4def8e57f567b0e058eba7ea7de7277e0e0cf9467d567f3913af7bd3812a999901'),
    (Input: 32;  Expected: '0x60e13c214f9ecc37ab48c67beda727612a635d9e67114c83b34ed44753a65d00a424fbc812f1ec16f93079d7ae97a939'),
    (Input: 33;  Expected: '0xdcc50f12c899f09c44901c549aae1d3d7341b2c6b78f2e566c671631d8df1e74ebf5b74f5230b92401ba9b74e75a4e67'),
    (Input: 34;  Expected: '0xf8a0491ef325a3af1ed02eac4e9bfd7ef645a1312318e0b5189300850ead5016194c39af296643dd5230c3b5cfa15479'),
    (Input: 63;  Expected: '0x2adbfe51413f5d3458581dc9b9ce713b6e96ff6208fa4716cd012710e6a2d834681d32b1915e661ebfcf8dedecc08c85'),
    (Input: 64;  Expected: '0x483f8d2065879e98c9640230d85cfffdcbf99543d7a2f24c045cf08ef8f53cb5472c93c1cd3655f35903ac91926ed2b8'),
    (Input: 65;  Expected: '0xc4397852b5944238dc167821e2f51e80ff736c0050b1abbd0400c8db1eeb4dc17e1fdc0ed9a0d61d2e2bc29ebbb583b9'),
    (Input: 100; Expected: '0x5526d6e720647cc23e1ab86a51c8e8601579b6952e5d610c4b450e41292e6acb073439b91fcdd75041f475530c033323'),
    (Input: 117; Expected: '0x7ade74e0a89e7ad77e76e9a35c04f67c933d8f4cab485d1628b0ced9ccc17f447ba38f81ebac28a4618abc006af4e5b4'),
    (Input: 127; Expected: '0x6e23e9d0dc3ee1ccb08f1f9568e8fc5d8d85b8b5a01afe63946894b39d68691330a63bbeaccc4fd6bac141c452feaa0e'),
    (Input: 128; Expected: '0x3b9d1126768bc0e16c6484a0025f492893a92927eb42cc645c23c22a6a5252bcb7b82ac748f0a99a49ce2ccdaafa723a'),
    (Input: 129; Expected: '0x2703c12554db5b80ef25b7d2dc4f0233b7b7064e69d57eff39b12aa77ad3c8b2e5d8014506179fc76399da952b2ed985'),
    (Input: 178; Expected: '0xc21fe026e7ba3c8e845512d39c592beddf903e6df81fb8ec0637464c279618b1f10a91b5291f1ab698d9354b61a3b2d6'),
    (Input: 199; Expected: '0x83843225d4dbfd455676885ea3b923ba2e0fa536a53c713365b5335623897840588d30260a4ed4d392c18efb6c96d946'),
    (Input: 200; Expected: '0xccfe1529f08bad44c42cf6bb96497f3474fe69631a33b58b4a28833e30dc7a404d63f5573dd81654e0430d92034b2b8b')
  );

  DATA_SHA2_512 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xf729f844e23dadbfcb53c046407f03e790a7a9ec6004c570feea461f76b066353dfc5cca95629360d5ea310719bf6f0251a56e9c515b62b863206d6ff64b6784'),
    (Input: 31;  Expected: '0x526be8f0afbc7ffe77f62456f8d47b2e60bdad5ff1955841d9bcf82d9a2c71a9a2bdf4288d025154ff43ba65b4d4adb97ac24f47c27a28af7af0b2d831c9c7a2'),
    (Input: 32;  Expected: '0x3bbcc5f450e9b6708c22ed0ba40b5265d3b32130b9ffdcd06bfc61c49452aaabc8bf08df544f55935952c80d0e266f27f3f66ab4aa1b2f3e7b58ee0708200d79'),
    (Input: 33;  Expected: '0x10279e84bf5f4debae99ebb1c2186a3b5a510da642c99cb77ab981f39fbf55d20ef70fcb19880b86929dd7db3a4b2259b4b86d82a38b200933d550c42d729a57'),
    (Input: 34;  Expected: '0xb5c4f53ee9d151543fdb42640650e4ff930d2f145ce1986d6a8b3b1860a0136ec889e4f02675a99e0118430c9c8357f974ee99d0e52b62b92016ac2c6833af5b'),
    (Input: 63;  Expected: '0xa35de82665a3c12424e5a11acc356b329a56b15bee61c2332ec04fee142ad7699f9834800e127c0146827d8b84ad1ce0b57f2c5ed30afc0768e098a5d621dd97'),
    (Input: 64;  Expected: '0x6dd15a36cb5ae97d7ba0c74e19adea2bb4c243839f58aeef83cd8527e87c43069d0a02804dbcb281636b8712f6e546f31946318a709019ed11f3816642eba77b'),
    (Input: 65;  Expected: '0xa2433136dc3bd4f0e2d4d14b6033e1002f675c4ce842d7baeee78b95193030c647af66f0e54ff94ae3b60e46a88314a4a145f30267f3fd0990c6ebc2970b9fbf'),
    (Input: 117; Expected: '0xb4647f67deb7347a18d43d87a4143853855fd81602baab1edd8a08b32a74268adb12fc03b6d1a05d81e67dc75fa93386749dc1d40d988a685ed1550a5849b527'),
    (Input: 100; Expected: '0xa55acfa8808e502b5f02e23f6f824b56fbf6e8bba3f032d7ffd5b254200de521299a4e8f593c453c1483773cc78332d54f1016af2cbddac68ae7fef7aa399219'),
    (Input: 127; Expected: '0xd33bc6775743bd1110f51b84c0ebbdc57c622890b20d53b754ad9a1937e2761a1747d9adcdc2ec685549e418eb6ec3943c1e88d8e4a698389542547256522fe7'),
    (Input: 128; Expected: '0xf03557fc390333279816513d69a4e389ab51df3bf1a06b666c816c18f98c8dedaf338eea98e3063cd728ebcafe7d59dd19eca2bef4327a3421eb1e921af5d223'),
    (Input: 129; Expected: '0x5af2f48f25c994054c624afd99c5c9a59e91c492facdb65068cc1a15497f65ba0f6c5d15dc2f176f10ea6130c2894339a02fb99696b39b6c634066acc590427c'),
    (Input: 178; Expected: '0x8dc7dbc6d4b1ccd92948804c6474e5f94acaf59f4d908f86603abd3c7d96f18dc1d1723a22cef7b6e0ef9a6c1c33f390c4c85a9e1fd4c4fd4db3c867564f1d81'),
    (Input: 199; Expected: '0xf239e971dfa284808c7e95a9726e1f42942e431e2c942e84d020c580a7a4a8c1a7ca35af44f2efafee6d3d929c01c30f0588c01e8e6813649fb86b22f0369cb1'),
    (Input: 200; Expected: '0x5a9aee4aed39dd405980b29984dccc6b520b685c6beb6e42c3450b858e1cc45de9d235849fa743738a06514b30522180d06f98185a49919191e86374a79df3b9')
  );

  DATA_SHA3_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x84b6a1cf6df74b3a54da73cf2ae3bca8426fba94908199bba45ba1ccc8f680d8'),
    (Input: 31;  Expected: '0x49128a80ce9b14b46c310adcdfc0be99266ecd0728b4a12a7fdaa000d49c4106'),
    (Input: 32;  Expected: '0x60c394688e6a2eba3d14edcebf6b13c95eea80a458bf3f557e55df0dd710bebe'),
    (Input: 33;  Expected: '0xfeb0146e6af5c99e7dc931f28fa2c965c1e16a9360bb7fc5eacbd6658115b114'),
    (Input: 34;  Expected: '0xc247d6b3649e736004601810655ba1e7041c40a73ee5fd5d408e891a90f38dbb'),
    (Input: 63;  Expected: '0xd3e6fd4abf153070e11446c6dd1cfe748064239a9f680437a4b1d51c5c64fa2c'),
    (Input: 64;  Expected: '0xc5d9eea9c7d04746dde6e94cee94105a5d1f173809849c2d2953e31b3af5d556'),
    (Input: 65;  Expected: '0x81bd225df0d6dd4ed5347dbf688b4940b9a0f085db9a5efd8fa4dddf5bea2e9d'),
    (Input: 100; Expected: '0x5746f720dab78746407d4c594fda4a2539949183a0208553c8aee1d578b72898'),
    (Input: 127; Expected: '0x4230dbf66b2e324d321fcbd6ffbfeb0156e3070af672dc0c743b5001d6e530ac'),
    (Input: 117; Expected: '0xade65df24b483b5d51e8620dd05966dd89b96c90b69322c19d67c3a968f5514d'),
    (Input: 128; Expected: '0xc19c584bb6969ba83731d2f21025d556b9cf08a9e598cc97cdc5f021675e7a90'),
    (Input: 129; Expected: '0x82ea34a1f09ebaf85ad11efa05f81e9e7a8d6fbb62e04cfed2e5f26c4d1f09b5'),
    (Input: 178; Expected: '0x471ea99294ac57486166be9a3e3da3cbf588adc0c6606c290dddd513632931ac'),
    (Input: 199; Expected: '0xaf6df45fdc24388fba66baa4484ace35cdd01aa6a0f9a635f564c1ba5b1fefd3'),
    (Input: 200; Expected: '0xcd31079dc52963c7753ff9b8640ce60404fd44fe4464af475229aa704cb5de4f')
  );

  DATA_SHA3_384 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xee2621cc2dc6f234c8976a1ac76a1eb8724213c67af5a704ba56a7bc92f09e146e1a1d7d0a5a4ae5405e8b9295fdf216'),
    (Input: 31;  Expected: '0xcac5638f7c264b72d01942b8109667b44142293cd1ad7bae06bcca65d82a5f72daf27070b17702415e9c3d501658ce57'),
    (Input: 32;  Expected: '0x509a74fbecb9d7cb23838a31bcd8447d73ae0893d2a60c53d6327467a2861e07b39ce800c01329ae2e06d1b3ecc905e3'),
    (Input: 33;  Expected: '0xcd6c73588fce7db1f3d59bdef9f544b6f08b2c50ec0b01dd012700d4274b80f4d0ff20ca774b27f04b31ef9f19bf0cc9'),
    (Input: 34;  Expected: '0xad76006715dd48f0138420ae2c3bd7d5e64ba735a307323c00192acbe837cec5cbe04312a1602ea757de41f18d0fde7f'),
    (Input: 63;  Expected: '0xddc1e64c8420ff5579eceac10844684d08cb769cf578925e59d98c79f5be736524ff44738a16543bba47d70b1ebcc36e'),
    (Input: 64;  Expected: '0xf29ec08d00ae2072137288e31990f2858629e23d2365a84a079cc5986dbcff1b16a19216aceb079e240e89626644bb3e'),
    (Input: 65;  Expected: '0x9a0bd293ed9ea460387266b65773bd73cd8c5c6ccadc0d1b901f35d1e82571a10b63bb90beeac3e1a0fc29786da0beb1'),
    (Input: 100; Expected: '0xaddb1229b53c3a35d1f974cfe7a1c3a6f6803996d72cbc13bf50376b85105b86b1fdeacdbe51525928e39e38ff23b1fc'),
    (Input: 117; Expected: '0x5c142da18a1e2b0f66f396e07cc102106227638a93d9cc5230b2c8ade550fab096049acb53fb5b357039983b77193460'),
    (Input: 127; Expected: '0xd3a0c04b1350044d29a099cb5d95175539e93e1144f471d27bbcae555864a3e7c87bbaf7107e8335206aebb2067c6e1d'),
    (Input: 128; Expected: '0x7538b4cc1d1fc9eb921f5bea8dda949b43e1f2e8fb7dbfd2f1e7b01f843dc5914fe7983cc29f53ea52c91da5e0e38a7c'),
    (Input: 129; Expected: '0x699fc858bf267ab42444dc5888f53e55c8bd7f195cda1bee192d9471fced05a25370f98d1e8a20127e57422fb226e499'),
    (Input: 178; Expected: '0x03c546e8f629538bdfe523e4776b9c4fce59b2c523a57482fcf212d617e63a7677b98ded0878b317e1514de278c58aec'),
    (Input: 199; Expected: '0xa2e0626bec9c34d571ec7079d0186b0235c45cc2faa165ca619c0ebd290f0292e7c565ee77fce106af58e0d30e7b673b'),
    (Input: 200; Expected: '0xaf0f60050d97927fa2becfd3b7938e31c20ff3576bc3adde5d51428e91de10102e3c49c24ae7e515838952e53709a67a')
  );

  DATA_SHA3_512 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x36b8e099d4afb54a9aadb5c76154be673a96967a73e462fb401c21282a2c4554b832f323415c047156e3452e77070a085d14543b123b473ed93d03248514898c'),
    (Input: 31;  Expected: '0xdfc10d8ec28d43efe3cbba1c1e1edcb6f71c14d9057941afc590469350402e8fe1298de2ba20eaa8280dea009668d5dde5f7001b65fb9237284c8b60e6bf4e8f'),
    (Input: 32;  Expected: '0xe4290dafe0838e10c8752074731d7fdb76c4d5d632f75f2c508b357d344c622b8e5aa9ba1d58f4c859bb49b4b81a25c1faecbc08317ceafc00e1c3a9945295a4'),
    (Input: 33;  Expected: '0xdde23aa602cca8efcfa9b026cf067ada1b8bc5487b4dc029b31621294d5be3954e402ddfb4e5f9a0401648e6e649a0f05f647e61457289f705ee167c86f6c3db'),
    (Input: 34;  Expected: '0xa54f15ec275b53cb618ca462bb0de1776e1038f2cbc40df2da6a7e5e1333ba475fcead9e0c55e357547feca9a973f781bc9e601c7570a0f510414e27167be834'),
    (Input: 63;  Expected: '0x6971211bc158034f3420850303953d8845f9657871af4d35d71f75eb086e69c07f4e63eb173962d53279400688ae3637d2fd742255b93e3ab6bbe1b203243586'),
    (Input: 64;  Expected: '0xdec734f489aefcd5ad355134ef6fd1ebb18c8f741d16e0fedb201dd801905a7f39c2824b67b2b995679c8266530b527e2dd2af59f044cc5d034d93bc7c35efdd'),
    (Input: 65;  Expected: '0x40b460c3f18d2c0aa076db67af63c3d22a6c3d29853ca642204d3ff5b0649b394f2e10beaf78be0929cb499b24323462ad7242a3e3e9c7b7a89a58da4358d1c5'),
    (Input: 100; Expected: '0x480d6ea46a25eeb45a2eaa1a23304d68dba624635772d26a21fe8fe56376de8d298bcb5f5d48e59aa6193a55170ae5a1d15f4f8dfe7fdef7706c0686eb39862f'),
    (Input: 117; Expected: '0x5b7e1c31bf4358a77f1afb7f2c181cde1bf87b3d9e94fed09d82a996364998ee3e46b9e7ab94337ad967878741475b2d11061de00d06e1db3026e2859ca2af32'),
    (Input: 127; Expected: '0x73b63d13c3e4e9dcd9fcce0adaeba4423ec201aa7e13e33faba2b6fbc35efd76302148fc964f7647b24d770ae897c9d5ca0211e4b1e27a81fb769ecbfefb1511'),
    (Input: 128; Expected: '0xd5ec5de877ef0a39eefe294f6183b63adb91d2a0ba1ec1fd576db515ed78f8220442c2347bdeb8a0f77cdc46d97e5b96d4189fec1f5cd2e8b5de3d467684ad73'),
    (Input: 129; Expected: '0x461f2ef3ddb3101d2ae5b1edea9178bc431225a9e5bec7c04e446a70db25f2e8e9b24547733667f0794286a330297d11215f21da7b5eea03adf063193f5f49bf'),
    (Input: 178; Expected: '0x3f71cc9ed5acf47e4b994fb36bdc306c7e777a400532e0c0ec7e2ac1796c4471d39a09d7e32473e7bf804e4b342813a87f8f11c85da3b08f50cfe8af3f690d12'),
    (Input: 199; Expected: '0xe2e4d8eadf49edf7c0b81c97e0c115064a6788eda531df390b88d09586dd2f33f551c6fe4f930caaf3e6d24e7f3dce49c9ecfedb5ceeef796c1afa1776157736'),
    (Input: 200; Expected: '0xd62ed867af9fee338bc1cc712fdbc0da15afa40b4a5dcc3e76d74f1770c5a7ca88638f0cc8bce685cae8d68a2aa8717c84bc3e146100aff25c3326355b1735aa')
  );

  DATA_RIPEMD160 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x734191cffedbbe96f14865d2eebe3650e54c6de6'),
    (Input: 31;  Expected: '0xf5c19350c4a7a79f1597b7172ff52205864c92e7'),
    (Input: 32;  Expected: '0x29c74325055e81d14d7165c28599e311c9b63c6a'),
    (Input: 33;  Expected: '0x1f54c3702f8dff024a6fae7ceb017a64f71b15a6'),
    (Input: 34;  Expected: '0x1068b29dd5bd6aec7cf04ffc1ef671cf83e7f239'),
    (Input: 63;  Expected: '0x5de126808d8b2656c8f91796eb2dd86a9fe65ad1'),
    (Input: 64;  Expected: '0xbf4c1c78a8e75584c6697fc2f1706e0c41c9df59'),
    (Input: 65;  Expected: '0x79123df7d67e2a3c3cdf3f1529deac143d44ca8c'),
    (Input: 100; Expected: '0xef7cdf0a7ded768b4675a743ac7ab64c3bc5fad3'),
    (Input: 117; Expected: '0xfb82dbfbb359e2f5fd3bc0a00a9bb7e873bda70d'),
    (Input: 127; Expected: '0x67073f8cb7f372f93bd57f289cf3829d801e78d6'),
    (Input: 128; Expected: '0xc923752f5fbb9721a48c5f1dbcfbc70865577869'),
    (Input: 129; Expected: '0x6ada1e777ecaacc07922cf839e1259d1f2b8afce'),
    (Input: 178; Expected: '0xabc2c368a457d10bc300954a4036b3a33eae7128'),
    (Input: 199; Expected: '0x31ed25a6a35ba860abc0804c6e8c3e3e6174099d'),
    (Input: 200; Expected: '0x1105e599abaea1b0f8d51c3878729ad0ca619a4e')
  );

  DATA_RIPEMD256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xb242099231d61f0d6c83044d360524b499a434d0ff12407296d1061e017bd023'),
    (Input: 31;  Expected: '0xe71778fbcc7b32156c66e244a6a07d10e463bb20cc35ed98c8cf35191ec013d3'),
    (Input: 32;  Expected: '0xd538e7bdd392ee4ec094a2a50cb6edec45537a87fd8f4a72a7fc573cd5ce43c7'),
    (Input: 33;  Expected: '0x7e1bbb5611223834cb1cee497b700c70cc27bbb042c2431fccd4ec67965567ee'),
    (Input: 34;  Expected: '0xa73d52f35585f3d4dd34850bf3e8de4697ad1f94cba71321d6784785f29ed905'),
    (Input: 63;  Expected: '0x48d647a2e1dc581b675daf26f0d08a11fff402a42c47d132f52133bb8a6895f4'),
    (Input: 64;  Expected: '0x2cefa11f6ea8dddd1d0c935b4f04f36c1631b1589eea6082ed53b3e9b54cfc72'),
    (Input: 65;  Expected: '0x5a2a91bab4ca44664ef1d16fb8f8cde48ba2dca1cc0c0faa636812b86b98fe3f'),
    (Input: 100; Expected: '0xa5fbe1faca66cc5d5f5dcea2550811254f221fb8761c4b5a3caf31f2f0534ad0'),
    (Input: 117; Expected: '0xf8cace5bd4fc6711706e6c3cfe9713234d40e4fafeb37b5dbe97c13c37f6ebc9'),
    (Input: 127; Expected: '0xd14265c897b77caa18c77c77c7f46f1a07faca209a16d997af794c15b145bb05'),
    (Input: 128; Expected: '0xb286ca27b0ae4f6c18886879f9713cd959fff512535bcd379943c95dcde7773f'),
    (Input: 129; Expected: '0xccfc63b15e2e810a36f3d26ed3b1bd49f456d1af97c3d46c0683833d37ce359f'),
    (Input: 178; Expected: '0xe6178a33180fdcad7cc503f5ed90b66610db900dee7326696cb4e10d1234caa7'),
    (Input: 199; Expected: '0x2a1c9d07ce2174a6a09a246c6edbdc4f0fd0514f0179984cb44c06b8b3c573b1'),
    (Input: 200; Expected: '0x29a962414ab1f46a2013178f831d66559a46d709fd3604b4b435ec4d8b536619')
  );

  DATA_RIPEMD320 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x3d9cd1561f939f3aa80ee5339fa11140e68f3dbcfdd928d4d31f6932a268bba329595cc1e347d06e'),
    (Input: 31;  Expected: '0x62dabb157501ee8aee1e7364942774f5741ed806f87f31d3754e956cda45c3423d31d5675cd7fcdd'),
    (Input: 32;  Expected: '0x286cbc2d0bd027673fdb6165c0281f3beabeafa2936d0d2b651010b473faa68fbad54c663c9d0fa2'),
    (Input: 33;  Expected: '0x921c28a7318df3bfca84091eb48ae54808fe79e9a24d716b641c61108272114a7c3e21614b316eb3'),
    (Input: 34;  Expected: '0xd569a0217a6bbbbd99e6f54899f14078adccc06b56be014bf3f25493763c7f6ebdb76fb0d187d0ba'),
    (Input: 63;  Expected: '0xffac8eacef53c8e9c9b9628ae080dbf8b50d9ccef6beaf0fc318f0921aeaa4624e478b48dff801fa'),
    (Input: 64;  Expected: '0x47f9c63000e89707be545cdf37e3697128b6ca013ea59ce576437125a35b94a1fc12b4568c2b42f7'),
    (Input: 65;  Expected: '0x0047b303eeff27dd6d3fd9ad838cb3eaac2d06b9f909729d449052bfb648c522e17f23beef18e14f'),
    (Input: 100; Expected: '0xd9eaaa5d3dbe16e6d2d06b1fdae8f5a6893303f82cf7ec838ee1b94a37ba2ecb8ccb008c149586bf'),
    (Input: 117; Expected: '0xdeff952e2a54873158c0cb880eb8c813f03716649006b9026dd9ba1556b9be4058ac4091c36693ac'),
    (Input: 127; Expected: '0xd5d5fbe5fb496f65ecc8f65b114bc498bad886b826e593fe0c66b0b03b868002be71c3219a992b61'),
    (Input: 128; Expected: '0x39bb7f49c9be805d4ff51210d6e64fc5b48a87ad4795e1c17deef630d4ab5f93bcee15b999fd81de'),
    (Input: 129; Expected: '0x1d18806ff98659458e4095e0acac282c1af2815cf5967402dad2c688afa4c10b16b6d1996415bf86'),
    (Input: 178; Expected: '0x957de878669f2a162f50a2c8bb07ae835b857985ef68f6c77d590b89861358698ed10fe59503b454'),
    (Input: 199; Expected: '0x527b23083ca9c12fe6f3e9936310f7b71c594113efaaeb58c195b657406a45a70f6d918e714ba450'),
    (Input: 200; Expected: '0xc56063dd1fb318af5a0910ed3993c3ea3f746be8ef65661af0fb4c7451f44dfcabfe7e5db469d9b3')
  );

  DATA_BLAKE2B : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x8f8a1cf77aad3d0421db8ae7b2a4752b811059d3a3a5cc3b00454ecd918f39936e2f8e23c5a96c6f4519f76e73981da24d2f8c4d3ef4e7002a17eef80e2a9514'),
    (Input: 31;  Expected: '0x4e074ec035707651726210950e241346aec8f6c6aaa504f416cd0ec92fa4c08340cca3827fb990d74b8f837c0bbafccb2d5739f2b59ff49cce5cfa4f285e083f'),
    (Input: 32;  Expected: '0xcb2c167bbad4d529cbdc48645756cf61b3838d6c0af14a9596dd105a172053e198c22c3669a792949274ff1ed687e80e4ae3b85ec70154a6f62d2cf13231b083'),
    (Input: 33;  Expected: '0x9a8a4ea7bbaf058c07a62a9f13de219abb2bd99738a7997bfaa373d61ce54c6a0ede112cb652d40682ff804552f9db4247de5858c45ccb9a8ac064881f05b92c'),
    (Input: 34;  Expected: '0xa7651109edfa702d76471ad0c4ffaaed200f5ed783a4ad834ced1b37bf4038af8472d767a7b0d08e146e079c4467468df30d89f14ae59fc75ecf927717abecdc'),
    (Input: 63;  Expected: '0xe24f626b1a12d956231a7bf17d7f976925cc186776da91543eb9b244454bc0b71956bce4e514bf1095fc61097eb39d67dc78ec6c78e640bcfb18fd110adaecfd'),
    (Input: 64;  Expected: '0x55de09270df2b8f2b8c35f082ae45acd55fca556fb4c7614a61531888e7d5502a2015b0c936fbddf4f6ccfcdba4d4e69139be2062c42a6b1acc03638b035d55e'),
    (Input: 65;  Expected: '0x51a424024d3eb88e2cf09e14e512a6ce27b1a95a087afe07c5138e191cbf8079fd740a262e47e6dffad44355548eebd2c1ebc24c8b7bbf266573b838a6b70ef8'),
    (Input: 100; Expected: '0x03cab91f85e1ffc286a297538200b80b39681f5fe06108557c354264127db6aaa271399af25c2cb240554921b3d878675f875dd244a7af22187015945b105558'),
    (Input: 117; Expected: '0xe9ca855bf340229a4446f46cb0b0e3cffaf1942b8a8b6e296d5b35621be9e6c40217a76d1461380d062e9f0ac8cee8e15b70b7762a6de367463ac84c4d56b49a'),
    (Input: 127; Expected: '0xab24840d31c5c19a8c5c0729e8bc327cb1b48088b135de8f04428985a0ef71d366388973625cb77d558f6dc4dcbe93c5d5327aedb83b0cbee34e656fde2962ee'),
    (Input: 128; Expected: '0xef4618e9126f6c54931e8f2ab5e12737ed4722932e107d05768ba59f484e0858b6b189ce0b1db3e18eea5355eb60dec5826be26cac759b7f2eab3a97ec111f10'),
    (Input: 129; Expected: '0xad7f01517787bfa75ceceab92d96f94f04600786a83cabe190e3b503af1d184d9db27577bdddb78fa052d8a086147add8ecc385b3f26c37180408311664bf9af'),
    (Input: 178; Expected: '0x99ae6a63885847e5b45ff4d2d2b0eb43e9fd722a0c7254eb4bcf706a484df9e300c61e6aa7c6620ddf2dabcc9b51257715f396f713606dbcd09f14c833becdb6'),
    (Input: 199; Expected: '0x33074a6aa23c6117037b426d16211bc41a29e38bf94bba4c2dce6659b0c4e5b63555a8b08a214905e1f795282a0a427cb90de7d3967d7ba975b58a7eb550eb3c'),
    (Input: 200; Expected: '0x6c5117105a9cf47347e5e59aeeacf833e503c3e537e75020c9363cdebafeab00dd478e96c3a0e11e4c2615284fddf47a079c2b49d650f0bbc167ba10f5bf25e8')
  );

  DATA_BLAKE2S : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xc6d5f10d213cfa97b3317f115f6eae29419051524f14f29b39c4f620a6e4758d'),
    (Input: 31;  Expected: '0x2c82e8af7b3db4a4737546616f34026c0acdf0c2037ba138861af29e34b2eaff'),
    (Input: 32;  Expected: '0xc661e40d5ef223343c2513b19b0ba5a69c91e076be875c854830345de2741517'),
    (Input: 33;  Expected: '0xfae74bb4a48f325c4380ab694ed91ed6b0bb5d8eac825ae8ade73d4b7d7d1cb7'),
    (Input: 34;  Expected: '0xd6010f74459a82f459604a044fb2d21d93904427c44ebb22bd76694110fbf9df'),
    (Input: 63;  Expected: '0x0707f52c9629e5d926d19aaac0e31f96273627ddfbb85519f4d2abdda8107459'),
    (Input: 64;  Expected: '0xc55f4dc5612258bd600c4b078128919dca82a4f98022b9762826d596356dda14'),
    (Input: 65;  Expected: '0x7ce4f4e9e7357f74f15903f273a285e02d7fa976e94ae900d9a14b131f397aec'),
    (Input: 100; Expected: '0x4be6010f72c375b685dd57d66585b8c5f86eb1ac27b80ca20f041d44533a7005'),
    (Input: 117; Expected: '0xa37bc13f537b8800fc61170dd714cb938c0e62047a7c9d0061bd8a407fe29a13'),
    (Input: 127; Expected: '0xef42bf26aeae6d85c8c1a0d4304da676444a7c57944efc0496c300b391048b01'),
    (Input: 128; Expected: '0x54afb0c19b2fc2ed628d379f819a79ad940add19296099acabe26bdc67c9bd05'),
    (Input: 129; Expected: '0x31e1c3e9ce27f992329d933a02dafe206b856f90057803d1e537304e97f80885'),
    (Input: 178; Expected: '0xf95e620f0335c83afa8eda36b853a739158cd4f8910fa2aa30d0794352c65510'),
    (Input: 199; Expected: '0xbd881d0cac02bd2300d41dfd8936570ed940d8cef9632731f28ea472d43c4199'),
    (Input: 200; Expected: '0xc83b8ea4503d8a8d470c0ba7f977c2ea773e844d36d9a9e866a953c1338259ee')
  );

  DATA_TIGER2_5_192 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x31f8163acae71a73f662828258b8506f2d8d65062b550d71'),
    (Input: 31;  Expected: '0x4c3a22c2d96ab29ad12100b1f2cf6c52b0f75f4c75f049d3'),
    (Input: 32;  Expected: '0x5072d1575f95f75eb22169647a0f5b774bdc21dd8896528f'),
    (Input: 33;  Expected: '0x3fb8ab4e655028dbf2aab6ebeee5996a93fe0b4bb250fb6f'),
    (Input: 34;  Expected: '0x026780bd79297995ef4b5e0d9cbdb1fdb4f6df4aa94abee6'),
    (Input: 63;  Expected: '0xc45fc6510ee3ff3503c4c8795d3d27da2fd4f81e5edef179'),
    (Input: 64;  Expected: '0x7e056bc56de5385d47eb3e3a218b5cab1894449b8e0b55fa'),
    (Input: 65;  Expected: '0x6b6e1f82c0ea6b6a4b40678c8fd1d8ebdd49f3dc657ebc6a'),
    (Input: 100; Expected: '0xcf38de0d363bb17ee67f510900a48f156fc9e8429097509f'),
    (Input: 117; Expected: '0xc15eba0aa26d3668b97f9abfa4bfa0513057f35874f50ab0'),
    (Input: 127; Expected: '0x24b3fec9a6235309ae17ee5a972503b60a3e8017b66cdf12'),
    (Input: 128; Expected: '0x61485315bdca303a54a23b3fdf5ab410092824c0bd8b177a'),
    (Input: 129; Expected: '0x742c2dc251630e13016a4f968e640156e44bf3c6fc307665'),
    (Input: 178; Expected: '0xeac22e2e763c29b07346c531917a0fcb93fbc72daab36681'),
    (Input: 199; Expected: '0x2b173dfd8256085aa6b8336b5ce6fbb3d383c59547e5547c'),
    (Input: 200; Expected: '0xc2eee732fdbcdc4b0c8f57187a69b7017f9ad8771fc5ae36')
  );

  DATA_SNEFRU_8_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x93fdb3c044cf11b551b7527a59c9eb9cfb1716adc8fc0e1926b246038677968c'),
    (Input: 31;  Expected: '0xfb7c3d09e37f3388d9a90ca09c87cea58c6efbb8462562f7a4572a3eea194ed8'),
    (Input: 32;  Expected: '0xc5c78eba6dae1f3c9aefbe8e6608c60889dd8c648efc7b02befccd8bab46c54f'),
    (Input: 33;  Expected: '0x448c94af0ceddab0a6c2d06eda05f3ad6484512cccc61fa32f902a8e9021b851'),
    (Input: 34;  Expected: '0x99bd6565cf0c34bb93b74c81e68c5c096731e927c04eb374032e5507ce20175f'),
    (Input: 63;  Expected: '0x81a91002867a3e930493d9c833655165c63062ea66d65c45f2b1b29fec0d245f'),
    (Input: 64;  Expected: '0x565e627a7ac890df042565377b1413b30ff2fc1bafa861fa9070526375936299'),
    (Input: 65;  Expected: '0x0116ec1a605e1c56137427e06599be0bfc243a191988a4ced8a5b461b6f9bf67'),
    (Input: 100; Expected: '0x2d5fc09951112a362dc542262351087594e3643160cf87733ef6bc48d9cbe673'),
    (Input: 117; Expected: '0x3278279bc38c7483c3c072a892702a9ba0ea909b8a3412a4b48f333c99735433'),
    (Input: 127; Expected: '0xb22280ba8e1c973424ddf5be20497e1191634f7c72f46cb0757eb46dac168839'),
    (Input: 128; Expected: '0xf456475f82364ff1c5b4d14509b2a06d5fc8512378ec4d909fa9c57c336d2bdb'),
    (Input: 129; Expected: '0xc3b087f29c8237981b10227dbed68b203408df8aeb1805089a7a723f02b51992'),
    (Input: 178; Expected: '0x0e13d6fc033f4de4e9db360292e7a8c02514534e2cdff6fd69cbdcb515c8760b'),
    (Input: 199; Expected: '0x72e8f1ef4c8425356593a9ce4be37181911bcff9d9f426c93aa1622348a2c6e7'),
    (Input: 200; Expected: '0x8ba028b1ad51b06d8a92cf3541c817a22c483fb8aa9c4341345faddb8e166867')
  );

  DATA_GRINDAHL512 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x0b25b53c3812cb38fee71eae043331d5486154d4277d63f571ed7621ba1f38816163c16e6445568cde5dd4926249a2293b4c96f1e99d7f0697e9b0be24987fd9'),
    (Input: 31;  Expected: '0x9c8b6c9737348ea89adf7d3742344c416ca80e70d0c1a574b66d03c3a51fc363645a09b07e6804705726cbb0fda30ad755713f10b1dcd4bbc71d8d975401766b'),
    (Input: 32;  Expected: '0x04790923e624227751ada31cb344e77ba8cfabea22b9d09fd2f0a867d679e8cbb70665be0fe81554d1a2add1b69bcfd59c8fa452dd7847461c688da80a22df5f'),
    (Input: 33;  Expected: '0xd0af72a4c6ba8d8a690405f09c794030ae8c134df8ca60af5de4cc71458c0accba769abcb7d1c1b833921d52d44bec149d35110a98d03776ab9fc576f44044cf'),
    (Input: 34;  Expected: '0xfcfd8e4226478060980bc67a6191f55e772f44327897ea518ed092277112de8e8df8780c630f712a4ee2b4387d945e20e9d1628c5d513ea5ae61f9f2ea476cba'),
    (Input: 63;  Expected: '0x24b3f7df2ac9e96aa9ce2245e77a3b96a5c1c3c9d070f6806340f65ea9478d4b92ad48b0289d2540a4dc62fa511243eb7ca9808b59425ecc12343b8aff83d4a2'),
    (Input: 64;  Expected: '0x8830b562ce16b7afaf42dcb1af79624856cdea734b88f7b9f26b147f6e8c716aa0bb48b329ffee5ba8d0a37f205de2dcc0d9359e7e133aae14a201d22e82e60e'),
    (Input: 65;  Expected: '0xcca9753de1a1a717c1dfb06a1b9fd3bc7bb01ef228d2b10ddbb8e36fcfd30ee2ce6fb4b63c091506cef5c5458f89dd11991b829a817870fa25253697d369265e'),
    (Input: 100; Expected: '0xead32ea9bb5b7db55c19895cf6b9ea82bd17ee4a56ac508f3bbeb69a0e5f4df8cf492a02ea5db195f74e6101314ae4917758e0642e8981d947c1dfa16cf651b0'),
    (Input: 117; Expected: '0x4447132202fd4a94ae31af19bf454d2c46e4e8a1f82ab214f3eadd9d02eb9d7ebc72ddbf04bab2e0e3a553f4e6ec5b7c8724f20c887c8394b2f970524a3b845f'),
    (Input: 127; Expected: '0xf924af50f7cdc77b9199d1af7f1f7fcd454b8b670df3a1d22ec634a502f509f47ff0d6ede8eb26afb94ee45ef819acdd522680a5a6394aee34704f9f08e1a37c'),
    (Input: 128; Expected: '0xc86054fb58498874529532408a05101ad0d1753639716f96f56468c015880d7adfc2db4b94edcb50af6e66f87a0d595f7e29a5829edba17c2d039141aec90724'),
    (Input: 129; Expected: '0x3db136d934e5c22fbbe614fb7420d9cd70d74d1e868e078bbab97939039124543b0909de500b72114a110b1a94a6dcab623b3f0ac9eb102176023719a8243561'),
    (Input: 178; Expected: '0xbe7c6b085ccfa21344e46415a3bb139ee2ac1b87ae569e3f751a563280e879cc7910c357416101495cca5442d6260bf993e11ba1d5aedccad75afd130d4346fa'),
    (Input: 199; Expected: '0xeeefc607804883a8e4e24d349297380a7be6789f877d6edfd017b054d6dff6a7fcb1386c5695b76ff9997332125a2e7aadb9533761a2d9fd960f6be4646fbaf3'),
    (Input: 200; Expected: '0x13771dd2bd4e1d046acd57457b0cddd6c535d91923677315ad89f7bf2fd3573b31d5eff98eb88798a5383b90d36efabc5b4127eb6e592adceb6a0749bae01869')
  );

  DATA_HAVAL_5_256 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x1c3afb53f06ade5399c4797800b44abc301d9faaf698fe66ca36b18a26da5153'),
    (Input: 31;  Expected: '0x4cccbbaf8e991a805626c96f3d2850862ae7e77e970a6e7b818444a7c92c8cf9'),
    (Input: 32;  Expected: '0xc5b81863a6c8c1ac6cc3f429a7fce6ff6ecb1f459856d241f5c5f1820f229927'),
    (Input: 33;  Expected: '0x6453387b3f0b6d6dd6a8343cab021ceeedef2f8fd852ab35a8aa5472f3653909'),
    (Input: 34;  Expected: '0x71dd44d1eb0ced6208ac71360611b7ac50cbc49365c135fa253771814f8fd224'),
    (Input: 63;  Expected: '0x09182c9035cd025d5cca7f2a9525bccdf8314d6c03419987a03a0bec59e76e38'),
    (Input: 64;  Expected: '0xd6cc048cdd7c944ad99b1bb8ff9b48bf8f8ecfa783369e3d008902fedd98009f'),
    (Input: 65;  Expected: '0xe7e1ead7bad22f210bfe98825022a71e9ebc8b85cf8710b2ef6fb9e457fb96db'),
    (Input: 100; Expected: '0xef0ecb677bee8f32a0e234f9f1944528a17f2e148634d7ee99d490c21898b245'),
    (Input: 117; Expected: '0x883de42fabd84a49dbc4a5cc6a71f6b8c8c2b2ce91eadce672a21b0df5d38683'),
    (Input: 127; Expected: '0x0c57f4b86511b060b39c9d7b101fc6282642654890fc9dfdd010025e632c9ce8'),
    (Input: 128; Expected: '0x63829e28fce75643700ebe1e4750fc26001c81335401b19b5e86acf3866e4672'),
    (Input: 129; Expected: '0xa29f9c16a35abbcc06d5f3e77854008dea21c38093729ec347cd3cf24ab6fdc8'),
    (Input: 178; Expected: '0xf83274137a08ac4f8738587e643a85907716f2df0462d32673f5d79c5e301e6a'),
    (Input: 199; Expected: '0x9d08dcbcffe809a60e60fcad8b515ed73e339e73f885c5b50479d7ea2afb6e3b'),
    (Input: 200; Expected: '0x5e1e2503132805abbdd447a5428dc9ddf7071da09fc5bede1a2db78731177fee')
  );

  DATA_MD5 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x990d2e3e54e0d540e17e28bf089cbc8f'),
    (Input: 31;  Expected: '0x5120a7106123521029896a89890decbb'),
    (Input: 32;  Expected: '0x49848dfebea23abc37872a22bb76e1ea'),
    (Input: 33;  Expected: '0x62b3040c9f11e5ef68f5b029beffb3ec'),
    (Input: 34;  Expected: '0x61c9c3ec798fdb6fc587065114a093b5'),
    (Input: 63;  Expected: '0x89973c44bb3e207dc60d789e3b9b482b'),
    (Input: 64;  Expected: '0xe2ae3f3eeffb99c0b46f12254ad6eb4e'),
    (Input: 65;  Expected: '0x3c2b0369b053d0df325c7343f0a5401a'),
    (Input: 100; Expected: '0x98e0bd2b4eb38f4d7e6d33d1cb5fbc1d'),
    (Input: 117; Expected: '0x135a0450af2b16e8529060246e402a27'),
    (Input: 127; Expected: '0x74f3b69ddcd9d6ce64530eeef42cec35'),
    (Input: 128; Expected: '0xed31bf5fd4dbc2d509ac4cb880ec685d'),
    (Input: 129; Expected: '0x2cacdddc8999a30233627b929921202b'),
    (Input: 178; Expected: '0xc6f6aae119ba216edf22c62ed898bc56'),
    (Input: 199; Expected: '0xc5fc302e8942cb54a37a7c46adeab3d0'),
    (Input: 200; Expected: '0x9242480e2630061d3eccb16821e98d30')
  );

  DATA_RADIOGATUN32 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x65024d09e2b8a46d8b6a2aa87af2445a9d640a74081e5d7a33062307a1c47b0d'),
    (Input: 31;  Expected: '0x32b17be7c6fedb037515313b5604e1661ca1f34e282107e20d3e907864751421'),
    (Input: 32;  Expected: '0xff4d011327d8dfccde7901523cd044fdc8c89479a831a61a8179ccb1eb6b34e7'),
    (Input: 33;  Expected: '0x92dd5fbface846262b32ebca67a20fa571a87c435c11daacaca4cd96da4c9c2a'),
    (Input: 34;  Expected: '0x289590b6bbe0da22917b8d62b5752c4ea032de707e753d98771da87e7a6f68d9'),
    (Input: 63;  Expected: '0xda5cf1e7f0b880c419201aeb2f537fe27594d9e239b738f1bc677d59f2927923'),
    (Input: 64;  Expected: '0x9b21fc33aa89b1a709c0af3b0305ee0ce491462ea34900d52f44682938f8b5ae'),
    (Input: 65;  Expected: '0xc2856589442488830608c6d9669f1d93bdb39c83616294499b36dffba17d2bc0'),
    (Input: 100; Expected: '0xbbda668f9d7b3cb2729b4a6a840b48ce3f938864d41a37a8b6c1df0926923291'),
    (Input: 117; Expected: '0x4e99747c8623d579b13f1cc6593a83c7a363d70157ae3a83165d817e836a22d0'),
    (Input: 127; Expected: '0x86517f426d2c55fd69d07a434f90bfee70539cde89f024dc1ba0e52d0ba5710a'),
    (Input: 128; Expected: '0xbb266e01e0ba48d3c8a5f465d41dde07c67396f05011b1eee0fc8c95e11b2525'),
    (Input: 129; Expected: '0x9935ccf10e79f6077845f4f6ad9a41df57a8ce7d854a0899090de8140ca38b67'),
    (Input: 178; Expected: '0x344442532a514e9dbb4b9c4232d45558e7e38510109ef62b17f54f402885cbde'),
    (Input: 199; Expected: '0xb76be67d94ce6014e5a125c371c22abfce3bbccc86f92dac31c394226b0c7912'),
    (Input: 200; Expected: '0x16696fe96e850fce272f90b59e9114e55098c03ee0d3e40e0d0616a1926a8ed8')
  );

  DATA_WHIRLPOOL : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xeb986421c1650306056d522a52f2ab6aec30a7fbd930dff6927e9ca6db63501c999102e1fc594a476ac7ec3b6dffb1bd5f3e69ed0f175216d923798e32cb8096'),
    (Input: 31;  Expected: '0x8ec8f6838a7f78f9a1104a15e6e51f690b8bfe69e412438a6591dd90ff1bdee732ee32b75eda9d679900081a17e10d1dec77fdaa109a6ede060bbf3fa7959a8b'),
    (Input: 32;  Expected: '0x5687a34495d2ebe57ee157fb0eb4c9674079d6ce97d70a091abfb92fb0096f2065197ea7379bbbfcb10a148beec4381bf2dd3662bcaeb9077a014d5d51acff7b'),
    (Input: 33;  Expected: '0x017cf76d956e88528f0d1f48dbf895c645f0d9a7269ea21df15da6e24e15d711edbf88f0a6872c2074afb0f5c2905291395862b02e06019ffea960aa92ae7f98'),
    (Input: 34;  Expected: '0xc5ef49c4ba2aadecadd8820034378e53174d66b6bee6583ea3d36dde0ebe652be2571f9c5713e38e98f433817b3cfd4d633e3cbf62e6091943ed241c0b8cae37'),
    (Input: 63;  Expected: '0x9d3afbcb5b7bb86e27378090dc4664abc46f87bd69dbdf2481a5a1c25ebc216eeae5bd9a900f996d1fe8749c7127986602bd1221b73ea7c3cebcfd2fcf529773'),
    (Input: 64;  Expected: '0x0a2cf63dfda157514c4d9a54198265b7d09100922c8a6431d2b29b62c74f0ad7a0b0c661005aa686d5e2cbb5cab76563ee883bcbe52a4f4f32f2852ce3793b4c'),
    (Input: 65;  Expected: '0xfe6b3567fbbb1f1490d263248ef4f8ee7136a0c7627abb229c98fb90bd91710a15f135dffe1ab84a31984b3cc4869e870e64168efead9b8921a6139cd84b387f'),
    (Input: 100; Expected: '0xc95fb60f44a4eeb27cab9718ec3e3e6bdcd4bc3e2e59124f64defceeb17acf90121b65bf4693ae094e76f0db8d6f309a8531a474b53f49d5c4a7686fb9261d4f'),
    (Input: 117; Expected: '0xdff715603eaff8b2cfd3e0aa49ee50b0afdfa445e4f4b4a2b148959c4b23c6594bf8e2c81228db3c57c147e3b8a2fb91763b9a7abc0bff48052c30a9117d6b04'),
    (Input: 127; Expected: '0x76a8e2c8f91308134eb2a6485f4c8b1ed186632f5d4a477d5e2bd591c1a5913f39c97baf4a89ec56d0b46de38e72df6d43a0e8101f65e1441b415e4200cbe313'),
    (Input: 128; Expected: '0x661dc7ddbc9cd25ce94dfba19b7941daf12ff9a0a9d1b151d691ace392ed9d6c8d8cd1c12b2f0fda9ea116291cf81f04aca12f40fa2c482976228eb703d64029'),
    (Input: 129; Expected: '0xa9cf1d955a634da1f5b1068d1a0d631948ccd947c2e44eaf20584a79a810070bc3d30a208d63c023146d8bff79571ae6a9d10c90baf3e0031a733016f4473356'),
    (Input: 178; Expected: '0x53ca52a4baa75c13ef909fb6f6ec680338902bda1269c6a7db456c187a40f5e9e0dfce6f3d151e3b533f1b18c0b35a955095b24c94bd75a69bca5c67720c8e24'),
    (Input: 199; Expected: '0x26c9f7bed820bef29e35521bb6e89ccba04ad473eb7f8d9e51952ed4d414b71da10e57fc2d30ac8d6405722af51456bb515553a9fa9108cd022d270b9fda6ffe'),
    (Input: 200; Expected: '0xd88dceef0776780b8439dd8338cd972734d6e973b4dc43b6d298622d9ed0a1ab3e9a37664ecbd14d4155c65cde93dcfd70707ba4dd7eecbf15af2a5ffee48d1e')
  );

  DATA_MURMUR3_32 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0xea99253f'),
    (Input: 31;  Expected: '0x1553afc2'),
    (Input: 32;  Expected: '0x9146e5ee'),
    (Input: 33;  Expected: '0x9d9efa16'),
    (Input: 34;  Expected: '0xdeffbebf'),
    (Input: 63;  Expected: '0x56311c1c'),
    (Input: 64;  Expected: '0x4dd59c1e'),
    (Input: 65;  Expected: '0xa96e7dea'),
    (Input: 100; Expected: '0x61afdbb2'),
    (Input: 117; Expected: '0x04d45504'),
    (Input: 127; Expected: '0x22f573a2'),
    (Input: 128; Expected: '0x545ab5d7'),
    (Input: 129; Expected: '0x45d66366'),
    (Input: 178; Expected: '0xeb1680c6'),
    (Input: 199; Expected: '0x33a16e6d'),
    (Input: 200; Expected: '0x442b55fe')
  );

  DATA_CHECKSUM : array[1..16] of TTestItem<Integer, UInt32> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: 3935905087),
    (Input: 31;  Expected: 357806018),
    (Input: 32;  Expected: 2437342702),
    (Input: 33;  Expected: 2644441622),
    (Input: 34;  Expected: 3741302463),
    (Input: 63;  Expected: 1446059036),
    (Input: 64;  Expected: 1305844766),
    (Input: 65;  Expected: 2842590698),
    (Input: 100; Expected: 1638914994),
    (Input: 117; Expected: 81024260),
    (Input: 127; Expected: 586511266),
    (Input: 128; Expected: 1415230935),
    (Input: 129; Expected: 1171678054),
    (Input: 178; Expected: 3944120518),
    (Input: 199; Expected: 866217581),
    (Input: 200; Expected: 1143690750)
  );

  DATA_MEMTRANSFORM_STANDARD : array[1..8] of TTestItem<String, String> = (
    (Input: '0x01020304050607';  Expected: '0x01020304050607'), { MEMTRANSFORM1 }
    (Input: '0x01020304050607';  Expected: '0x05060704010203'), { MEMTRANSFORM2 }
    (Input: '0x01020304050607';  Expected: '0x07060504030201'), { MEMTRANSFORM3 }
    (Input: '0x01020304050607';  Expected: '0x01050206030704'), { MEMTRANSFORM4 }
    (Input: '0x01020304050607';  Expected: '0x05010602070304'), { MEMTRANSFORM5 }
    (Input: '0x01020304050607';  Expected: '0x03070304060406'), { MEMTRANSFORM6 }
    (Input: '0x01020304050607';  Expected: '0x01040C2050C0C1'), { MEMTRANSFORM7 }
    (Input: '0x01020304050607';  Expected: '0x0101C08050301C')  { MEMTRANSFORM8 }
  );

  DATA_MEMTRANSFORM1 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x4f550200ca022000bb718b4b00d6f74478'),
    (Input: 31;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551'),
    (Input: 32;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f6'),
    (Input: 33;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f638'),
    (Input: 34;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858'),
    (Input: 63;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c5'),
    (Input: 64;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530'),
    (Input: 65;  Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c53021'),
    (Input: 100; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e'),
    (Input: 117; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939'),
    (Input: 127; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d6'),
    (Input: 128; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d636'),
    (Input: 129; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666'),
    (Input: 178; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b'),
    (Input: 199; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b000000'),
    (Input: 200; Expected: '0x4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b00000000')
  );

   DATA_MEMTRANSFORM2 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x718b4b00d6f74478bb4f550200ca022000'),
    (Input: 31;  Expected: '0x78c332f5fb310507e55a9ef9b38551444f550200ca022000bb718b4b00d6f7'),
    (Input: 32;  Expected: '0x78c332f5fb310507e55a9ef9b38551f64f550200ca022000bb718b4b00d6f744'),
    (Input: 33;  Expected: '0xc332f5fb310507e55a9ef9b38551f638784f550200ca022000bb718b4b00d6f744'),
    (Input: 34;  Expected: '0xc332f5fb310507e55a9ef9b38551f638584f550200ca022000bb718b4b00d6f74478'),
    (Input: 63;  Expected: '0x3858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c5f64f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551'),
    (Input: 64;  Expected: '0x3858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c5304f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f6'),
    (Input: 65;  Expected: '0x58e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c53021384f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f6'),
    (Input: 100; Expected: '0x5b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b073'),
    (Input: 117; Expected: '0x418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939c84f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865f'),
    (Input: 127; Expected: '0x211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d6304f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c5'),
    (Input: 128; Expected: '0x211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d6364f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530'),
    (Input: 129; Expected: '0x1f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666214f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530'),
    (Input: 178; Expected: '0x17506f6c796d696e65722e506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd'),
    (Input: 199; Expected: '0x506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b0000002e4f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e6572'),
    (Input: 200; Expected: '0x506f6c796d696e65722e506f6c796d6939303030303030302184d63666eb166619e925cef2a306549bbc4d6f4da3bdf28b4393d5c1856f0ee3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855000000006d68295b000000004f550200ca022000bb718b4b00d6f74478c332f5fb310507e55a9ef9b38551f63858e3f7c86dbd00200006f69afae8a6b0735b6acfcc58b7865fc8418897c530211f19140c9f95f24532102700000000000003000300a297fd17506f6c796d696e65722e')
  );

  DATA_MEMTRANSFORM3 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x7844f7d6004b8b71bb002002ca0002554f'),
    (Input: 31;  Expected: '0x5185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 32;  Expected: '0xf65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 33;  Expected: '0x38f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 34;  Expected: '0x5838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 63;  Expected: '0xc5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 64;  Expected: '0x30c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 65;  Expected: '0x2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 100; Expected: '0x2e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 117; Expected: '0x39696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 127; Expected: '0xd684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 128; Expected: '0x36d684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 129; Expected: '0x6636d684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 178; Expected: '0x9b64e441ae2724b96f99c8f4fb9a141cfc9842c4b0e30e6f85c1d593438bf2bda34d6f4dbc9b5406a3f2ce25e9196616eb6636d684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 199; Expected: '0x0000005b29686d0000000055b852781b9995a44c939b64e441ae2724b96f99c8f4fb9a141cfc9842c4b0e30e6f85c1d593438bf2bda34d6f4dbc9b5406a3f2ce25e9196616eb6636d684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f'),
    (Input: 200; Expected: '0x000000005b29686d0000000055b852781b9995a44c939b64e441ae2724b96f99c8f4fb9a141cfc9842c4b0e30e6f85c1d593438bf2bda34d6f4dbc9b5406a3f2ce25e9196616eb6636d684213030303030303039696d796c6f502e72656e696d796c6f502e72656e696d796c6f5017fd97a20003000300000000000027103245f2959f0c14191f2130c5978841c85f86b758cccf6a5b73b0a6e8fa9af606002000bd6dc8f7e35838f65185b3f99e5ae5070531fbf532c37844f7d6004b8b71bb002002ca0002554f')
  );

  DATA_MEMTRANSFORM4 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x4f71558b024b0000cad602f720440078bb'),
    (Input: 31;  Expected: '0x4f7855c3023200f5cafb023120050007bbe5715a8b9e4bf900b3d685f75144'),
    (Input: 32;  Expected: '0x4f7855c3023200f5cafb023120050007bbe5715a8b9e4bf900b3d685f75144f6'),
    (Input: 33;  Expected: '0x4fc3553202f500fbca310205200700e5bb5a719e8bf94bb30085d651f7f6443878'),
    (Input: 34;  Expected: '0x4fc3553202f500fbca310205200700e5bb5a719e8bf94bb30085d651f7f644387858'),
    (Input: 63;  Expected: '0x4f38555802e300f7cac8026d20bd0000bb2071008b064bf6009ad6faf7e844a678b0c373325bf56afbcf31cc055807b7e5865a5f9ec8f941b388859751c5f6'),
    (Input: 64;  Expected: '0x4f38555802e300f7cac8026d20bd0000bb2071008b064bf6009ad6faf7e844a678b0c373325bf56afbcf31cc055807b7e5865a5f9ec8f941b388859751c5f630'),
    (Input: 65;  Expected: '0x4f5855e302f700c8ca6d02bd20000020bb0071068bf64b9a00fad6e8f7a644b07873c35b326af5cffbcc315805b70786e55f5ac89e41f988b39785c55130f62138'),
    (Input: 100; Expected: '0x4f5b556a02cf00ccca5802b72086005fbbc871418b884b9700c5d630f721441f7819c314320cf59ffb9531f205450732e5105a279e00f900b30085005100f60038035800e303f700c8a26d97bdfd00172050006f066cf6799a6dfa69e86ea665b072732e'),
    (Input: 117; Expected: '0x4f415588029700c5ca300221201f0019bb14710c8b9f4b9500f2d645f73244107827c3003200f500fb00310005000703e5005a039e00f9a2b39785fd5117f650386f586ce379f76dc8696d6ebd650072202e0050066ff66c9a79fa6de869a66eb06573725b2e6a50cf6fcc6c5879b76d86695f39c8'),
    (Input: 127; Expected: '0x4f21551f02190014ca0c029f209500f2bb4571328b104b270000d600f70044007800c3003203f500fb03310005a20797e5fd5a179e50f96fb36c8579516df669386e5865e372f72ec8506d6fbd6c0079206d0069066ef6659a72fa2ee850a66fb06c73795b6d6a69cf39cc305830b73086305f30c830413088219784c5d630'),
    (Input: 128; Expected: '0x4f21551f02190014ca0c029f209500f2bb4571328b104b270000d600f70044007800c3003203f500fb03310005a20797e5fd5a179e50f96fb36c8579516df669386e5865e372f72ec8506d6fbd6c0079206d0069066ef6659a72fa2ee850a66fb06c73795b6d6a69cf39cc305830b73086305f30c830413088219784c5d63036'),
    (Input: 129; Expected: '0x4f1f55190214000cca9f029520f20045bb3271108b274b000000d600f70044007800c3033200f503fb0031a2059707fde5175a509e6ff96cb379856d5169f66e38655872e32ef750c86f6d6cbd79006d2069006e0665f6729a2efa50e86fa66cb079736d5b696a39cf30cc305830b73086305f30c8304121888497d6c536306621'),
    (Input: 178; Expected: '0x4f175550026f006cca79026d2069006ebb6571728b2e4b50006fd66cf779446d7869c36e3265f572fb2e3150056f076ce5795a6d9e69f939b33085305130f63038305830e330f721c8846dd6bd36006620eb00160666f6199ae9fa25e8cea6f2b0a373065b546a9bcfbccc4d586fb74d86a35fbdc8f2418b88439793c5d530c121851f6f190e14e30cb09fc49542f29845fc321c1014279a00fb00f400c80099006f00b90324002703ae0041a2e49764fd9b'),
    (Input: 199; Expected: '0x4f50556f026c0079ca6d0269206e0065bb72712e8b504b6f006cd679f76d44697839c3303230f530fb30313005300730e5215a849ed6f936b36685eb5116f666381958e9e325f7cec8f26da3bd060054209b00bc064df66f9a4dfaa3e8bda6f2b08b73435b936ad5cfc1cc85586fb70e86e35fb0c8c44142889897fcc51c3014219a1ffb19f414c80c999f6f95b9f224452732ae104127e40064009b0093004c00a400950399001b03780052a2b89755fd00170050006f006c6d79686d29695b6e00650072002e'),
    (Input: 200; Expected: '0x4f50556f026c0079ca6d0269206e0065bb72712e8b504b6f006cd679f76d44697839c3303230f530fb30313005300730e5215a849ed6f936b36685eb5116f666381958e9e325f7cec8f26da3bd060054209b00bc064df66f9a4dfaa3e8bda6f2b08b73435b936ad5cfc1cc85586fb70e86e35fb0c8c44142889897fcc51c3014219a1ffb19f414c80c999f6f95b9f224452732ae104127e40064009b0093004c00a400950399001b03780052a2b89755fd00170050006f006c6d79686d29695b6e00650072002e00')
  );

  DATA_MEMTRANSFORM5 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x714f8b554b020000d6caf70244207800bb'),
    (Input: 31;  Expected: '0x784fc3553202f500fbca310205200700e5bb5a719e8bf94bb30085d651f744'),
    (Input: 32;  Expected: '0x784fc3553202f500fbca310205200700e5bb5a719e8bf94bb30085d651f7f644'),
    (Input: 33;  Expected: '0xc34f3255f502fb0031ca05020720e5005abb9e71f98bb34b850051d6f6f7384478'),
    (Input: 34;  Expected: '0xc34f3255f502fb0031ca05020720e5005abb9e71f98bb34b850051d6f6f738445878'),
    (Input: 63;  Expected: '0x384f5855e302f700c8ca6d02bd20000020bb0071068bf64b9a00fad6e8f7a644b07873c35b326af5cffbcc315805b70786e55f5ac89e41f988b39785c551f6'),
    (Input: 64;  Expected: '0x384f5855e302f700c8ca6d02bd20000020bb0071068bf64b9a00fad6e8f7a644b07873c35b326af5cffbcc315805b70786e55f5ac89e41f988b39785c55130f6'),
    (Input: 65;  Expected: '0x584fe355f702c8006dcabd020020200000bb0671f68b9a4bfa00e8d6a6f7b04473785bc36a32cff5ccfb5831b70586075fe5c85a419e88f997b3c585305121f638'),
    (Input: 100; Expected: '0x5b4f6a55cf02cc0058cab70286205f00c8bb4171888b974bc50030d621f71f44197814c30c329ff595fbf2314505320710e5275a009e00f900b30085005100f60338005803e300f7a2c8976dfdbd170050206f006c0679f66d9a69fa6ee865a672b02e73'),
    (Input: 117; Expected: '0x414f88559702c50030ca21021f20190014bb0c719f8b954bf20045d632f71044277800c3003200f500fb00310005030700e5035a009ea2f997b3fd85175150f66f386c5879e36df769c86e6d65bd72002e2050006f066cf6799a6dfa69e86ea665b072732e5b506a6fcf6ccc79586db76986395fc8'),
    (Input: 127; Expected: '0x214f1f55190214000cca9f029520f20045bb3271108b274b000000d600f70044007800c3033200f503fb0031a2059707fde5175a509e6ff96cb379856d5169f66e38655872e32ef750c86f6d6cbd79006d2069006e0665f6729a2efa50e86fa66cb079736d5b696a39cf30cc305830b73086305f30c8304121888497d6c530'),
    (Input: 128; Expected: '0x214f1f55190214000cca9f029520f20045bb3271108b274b000000d600f70044007800c3033200f503fb0031a2059707fde5175a509e6ff96cb379856d5169f66e38655872e32ef750c86f6d6cbd79006d2069006e0665f6729a2efa50e86fa66cb079736d5b696a39cf30cc305830b73086305f30c8304121888497d6c53630'),
    (Input: 129; Expected: '0x1f4f195514020c009fca9502f220450032bb1071278b004b000000d600f70044007803c3003203f500fba2319705fd0717e5505a6f9e6cf979b36d8569516ef6653872582ee350f76fc86c6d79bd6d0069206e00650672f62e9a50fa6fe86ca679b06d73695b396a30cf30cc305830b73086305f30c821418488d69736c5663021'),
    (Input: 178; Expected: '0x174f50556f026c0079ca6d0269206e0065bb72712e8b504b6f006cd679f76d4469786ec3653272f52efb50316f056c0779e56d5a699e39f930b33085305130f63038305830e321f784c8d66d36bd6600eb201600660619f6e99a25facee8f2a6a3b00673545b9b6abccf4dcc6f584db7a386bd5ff2c88b4143889397d5c5c13085216f1f0e19e314b00cc49f429598f2fc451c3214109a27fb00f400c80099006f00b90024032700ae034100e4a264979bfd'),
    (Input: 199; Expected: '0x504f6f556c0279006dca69026e20650072bb2e71508b6f4b6c0079d66df76944397830c3303230f530fb30313005300721e5845ad69e36f966b3eb85165166f61938e95825e3cef7f2c8a36d06bd54009b20bc004d066ff64d9aa3fabde8f2a68bb04373935bd56ac1cf85cc6f580eb7e386b05fc4c842419888fc971cc514309a21fb1ff419c814990c6f9fb99524f22745ae324110e42764009b0093004c00a400950099031b0078035200b8a2559700fd00170050006f6d6c6879296d5b69006e006500722e'),
    (Input: 200; Expected: '0x504f6f556c0279006dca69026e20650072bb2e71508b6f4b6c0079d66df76944397830c3303230f530fb30313005300721e5845ad69e36f966b3eb85165166f61938e95825e3cef7f2c8a36d06bd54009b20bc004d066ff64d9aa3fabde8f2a68bb04373935bd56ac1cf85cc6f580eb7e386b05fc4c842419888fc971cc514309a21fb1ff419c814990c6f9fb99524f22745ae324110e42764009b0093004c00a400950099031b0078035200b8a2559700fd00170050006f6d6c6879296d5b69006e00650072002e')
  );

  DATA_MEMTRANSFORM6 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x1a02c820cac0d6b3bb3711f5d6ca49ab71'),
    (Input: 31;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736441ed0b1f95458c507be4070be32158f'),
    (Input: 32;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a7b90487b3339c7ae5bc74bab0f5e4343c'),
    (Input: 33;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a77877a3538579fbbe5a5e768e7afb23c587'),
    (Input: 34;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a760176df4514fb1d99ee1948c4e312d0276bb'),
    (Input: 63;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff68ac28a41025da6b7e3bd44215ba547e29039a803fd3125075837560e50dd69'),
    (Input: 64;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff57f9095888bca7f860c2947846a8d84f4de2bc86f0d370527e5e7f331446609ce'),
    (Input: 65;  Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff5386e65c7974243e85f3dc6d387cfbcac37c865da0f61c70307c55a23947b72b2ae'),
    (Input: 100; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c6127676ea36f596cd4219cb69774f74778c032f5fb310507c24aacbc4110cefa2c41fcd6f8a82a8861c859702da22469da28'),
    (Input: 117; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f1504c8763c6f79a66d702ec914e5226daf9b2b28ed40909558687e8935ceee4e12f3f63b58e0f7c86dbd00202716c4df087d39bc674275eefc9d200e1e'),
    (Input: 127; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a53099d12330fa3210308b41b2226daf9b2b28ed40909558687e8935ced7c1e03f9f55218f98987a4097820005f699fae8a6b0735b4ddffe1d4513c0c4559188e4'),
    (Input: 128; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a5e079838621fa3210308b41bb7269bb8e2817931c879e5f6c6a9c36f1a99df7349851359a9ba73daafdb7a206f59af9e8a6b0735b6ae8dc6af274ca574d9c8eda11'),
    (Input: 129; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a5e0212963d484eb3210308b41bb7b39bf9a3d14ac62db89546b6e8823f296e3ab239356318e8ea402ed17dd97a4f699faeba6b0735b6acfeb4885c3ad5dde8483dc2f'),
    (Input: 178; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a5e08d70f0eb51522722ee4fc846446153866408613cf69d89a5ffd431e641642504b9d4e843bffb4ce358845b70314bd20b68609b4b6af00ea34b9b158cba74f6e90683f2c8d373e38eb05b156dbc4bed6887b66ff871b8aeac5d5873764422edf09c2c5f694b6f502e72656e6a6d7a6ccdc7ea'),
    (Input: 199; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a5e08d70f0eb51522722ee4fc846446153866408613cf69d89a5ffdf31822aed00000572002e4f55025be36a4d00bb718b1eb8848f5fe15696b968aa61e3a4f4b9dd0aeac83ecca379e3d4912542e4b0e5f8f57f29732330d098726f15d8cbe353158e3437fe04f600721a74f3c493b631173030303030303a696e79cef8ad39220a02100010020a22'),
    (Input: 200; Expected: '0x1a02c820cac0d6b3bbc7ca02bf6736a76014a5bd20f0604ec33103efd9891ff53e0d93677737000000030335ea3f15040b5c3f15040b5c3f150409000000a5e08d70f0eb51522722ee4fc846446153866408613cf69d89a5ffdf31822aed0000057200004f550200912b486dbb718b4b556ea53c635aa751b7a29e63011b30de973c3e6ff0ac186ddc71419862c4b61594956d6765e018e13d71fbfae91274dadc9166c2ef3af00d6a897e9473e4940630303030303033396a6ddbfb92477e1d0917040417091d7e')
  );

  DATA_MEMTRANSFORM7 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x4faa0800ac400800bbe22e5a00dafd2278'),
    (Input: 31;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb054'),
    (Input: 32;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b'),
    (Input: 33;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38'),
    (Input: 34;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b0'),
    (Input: 63;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f271'),
    (Input: 64;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118'),
    (Input: 65;  Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f2711821'),
    (Input: 100; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac971'),
    (Input: 117; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93'),
    (Input: 127; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b5'),
    (Input: 128; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b51b'),
    (Input: 129; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b51b66'),
    (Input: 178; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b51b66d75833913d4967f24718a2b99753b74d47f697b868e4eac10bbd703e16312198f970a0a97f3d6499dee62172d550726437'),
    (Input: 199; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b51b66d75833913d4967f24718a2b99753b74d47f697b868e4eac10bbd703e16312198f970a0a97f3d6499dee62172d5507264374e624ab2668d78a4e2aa000000006dd0a4da000000'),
    (Input: 200; Expected: '0x4faa0800ac400800bbe22e5a00dafd227887c8afbf264183e5b47acf3bb0547b38b08fbf8cad6f00200018b7a95f3a53b0e66d53fc9916db86be230a88f27118213e64a0c0f36579456440390000000000000c003000a8cbfd2e417bc62f5bb46ecac97105ed1bbc6dd2b92b27c514b76cf2b54b93060c183060c0811290b51b66d75833913d4967f24718a2b99753b74d47f697b868e4eac10bbd703e16312198f970a0a97f3d6499dee62172d5507264374e624ab2668d78a4e2aa000000006dd0a4da00000000')
  );

  DATA_MEMTRANSFORM8 : array[1..16] of TTestItem<Integer, String> = (
    { NOTE: Input denotes the number of bytes to take from DATA_BYTES when executing test }
    (Input: 17;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878'),
    (Input: 31;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45'),
    (Input: 32;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed'),
    (Input: 33;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed38'),
    (Input: 34;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382c'),
    (Input: 63;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc17'),
    (Input: 64;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760'),
    (Input: 65;  Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc176021'),
    (Input: 100; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5'),
    (Input: 117; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d93'),
    (Input: 127; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b'),
    (Input: 128; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b6c'),
    (Input: 129; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b6c66'),
    (Input: 178; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b6c66f585cc914f949df2d1818ab9e535de4dd16f5eb81a4eabc1c2dbc13e851384987e0782a9dfd39199b76e84727505c964cd'),
    (Input: 199; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b6c66f585cc914f949df2d1818ab9e535de4dd16f5eb81a4eabc1c2dbc13e851384987e0782a9dfd39199b76e84727505c964cde4894aac663678292eaa000000006d344a6b000000'),
    (Input: 200; Expected: '0x4faa8000ac108000bbb8e26900b6df8878e18cbebf89140ee52da73f3b2c45ed382cf8fe8c6bf600200081dea9d7a34db0b9d64dfc66616f86af322888bc1760218f4682c0fc56e5451904e4000000000000c00030008a2ffd8b14edc6cbb5d26eb29cc5057bb1f26db49bac277141de6cbc5b2d9381c06030180c0612245b6c66f585cc914f949df2d1818ab9e535de4dd16f5eb81a4eabc1c2dbc13e851384987e0782a9dfd39199b76e84727505c964cde4894aac663678292eaa000000006d344a6b00000000')
  );

{ TRandomHashTest }

procedure TRandomHashTest.SetUp;
begin
  inherited;
end;

procedure TRandomHashTest.TearDown;
begin
  inherited;
end;

procedure TRandomHashTest.TestRandomHash_Standard;
var
  LCase : TTestItem<String, String>;
begin
  for LCase in DATA_RANDOMHASH_STANDARD do
    AssertEquals(ParseBytes(LCase.Expected), TRandomHash.Compute(ParseBytes(LCase.Input)));
    //WriteLn(Format('%s', [Bytes2Hex(TRandomHash.Compute(ParseBytes(LCase.Input)), True)]));
end;

procedure TRandomHashTest.TestRandomHash;
var
  LInput : TBytes;
  LCase : TTestItem<Integer, String>;
begin
  for LCase in DATA_RANDOMHASH do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_BYTES), 0, LCase.Input);
    AssertEquals(ParseBytes(LCase.Expected), TRandomHash.Compute(LInput));
    //WriteLn(Format('%s', [Bytes2Hex(TRandomHash.Compute(LInput), True)]));
  end;
end;

procedure TRandomHashTest.TestSHA2_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA2_256(), DATA_SHA2_256);
end;

procedure TRandomHashTest.TestSHA2_384;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA2_384(), DATA_SHA2_384);
end;

procedure TRandomHashTest.TestSHA3_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_256(), DATA_SHA3_256);
end;

procedure TRandomHashTest.TestSHA3_384;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_384(), DATA_SHA3_384);
end;

procedure TRandomHashTest.TestSHA3_512;
begin
  TestSubHash(THashFactory.TCrypto.CreateSHA3_512(), DATA_SHA3_512);
end;

procedure TRandomHashTest.TestRIPEMD160;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD160(), DATA_RIPEMD160);
end;

procedure TRandomHashTest.TestRIPEMD256;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD256(), DATA_RIPEMD256);
end;

procedure TRandomHashTest.TestRIPEMD320;
begin
  TestSubHash(THashFactory.TCrypto.CreateRIPEMD320(), DATA_RIPEMD320);
end;

procedure TRandomHashTest.TestBLAKE2B;
begin
  TestSubHash(THashFactory.TCrypto.CreateBlake2B(), DATA_BLAKE2B);
end;

procedure TRandomHashTest.TestBLAKE2S;
begin
  TestSubHash(THashFactory.TCrypto.CreateBlake2S(), DATA_BLAKE2S);
end;

procedure TRandomHashTest.TestTIGER2_5_192;
begin
  TestSubHash(THashFactory.TCrypto.CreateTiger2_5_192(), DATA_TIGER2_5_192);
end;

procedure TRandomHashTest.TestSNEFRU_8_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateSnefru_8_256(), DATA_SNEFRU_8_256);
end;

procedure TRandomHashTest.TestGRINDAHL512;
begin
  TestSubHash(THashFactory.TCrypto.CreateGrindahl512(), DATA_GRINDAHL512);
end;

procedure TRandomHashTest.TestHAVAL_5_256;
begin
  TestSubHash(THashFactory.TCrypto.CreateHaval_5_256(), DATA_HAVAL_5_256);
end;

procedure TRandomHashTest.TestMD5;
begin
  TestSubHash(THashFactory.TCrypto.CreateMD5(), DATA_MD5);
end;

procedure TRandomHashTest.TestRADIOGATUN32;
begin
  TestSubHash(THashFactory.TCrypto.CreateRadioGatun32(), DATA_RADIOGATUN32);
end;

procedure TRandomHashTest.TestWHIRLPOOL;
begin
  TestSubHash(THashFactory.TCrypto.CreateWhirlPool(), DATA_WHIRLPOOL);
end;

procedure TRandomHashTest.TestMURMUR3_32;
begin
  TestSubHash(THashFactory.THash32.CreateMurmurHash3_x86_32(), DATA_MURMUR3_32);
end;

procedure TRandomHashTest.TestSubHash(AHasher : IHash; const ATestData : array of TTestItem<Integer, String>);
var
  LInput : TBytes;
  LCase : TTestItem<Integer, String>;
begin
  for LCase in ATestData do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_BYTES), 0, LCase.Input);
    AssertEquals(ParseBytes(LCase.Expected), AHasher.ComputeBytes(LInput).GetBytes);
  end;
end;

procedure TRandomHashTest.TestChecksum_1;
var
  LInput : TBytes;
  LCase : TTestItem<Integer, UInt32>;
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  for LCase in DATA_CHECKSUM do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_BYTES), 0, LCase.Input);
    AssertEquals(LCase.Expected, LHasher.CheckSum(LInput));
  end;
end;

procedure TRandomHashTest.TestChecksum_2;
var
  LInput : TBytes;
  LInputs : TArray<TBytes>;
  LCase : TTestItem<Integer, UInt32>;
  LHasher : TRandomHash;
  LDisposables : TDisposables;
  i : UInt32;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  for LCase in DATA_CHECKSUM do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_BYTES), 0, LCase.Input);
    // Split into arrays of 1 byte
    SetLength(LInputs, Length(LInput));
    for i := 0 to Pred(Length(LInput)) do begin
      SetLength(LInputs[i], 1);
      LInputs[i][0] := LInput[i];
    end;
    AssertEquals(LCase.Expected, LHasher.CheckSum(LInputs));
  end;
end;

procedure TRandomHashTest.MemTransform_Standard;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  AssertEquals('MemTransform1', ParseBytes(DATA_MEMTRANSFORM_STANDARD[1].Expected), LHasher.MemTransform1( ParseBytes(DATA_MEMTRANSFORM_STANDARD[1].Input)));
  AssertEquals('MemTransform2', ParseBytes(DATA_MEMTRANSFORM_STANDARD[2].Expected), LHasher.MemTransform2( ParseBytes(DATA_MEMTRANSFORM_STANDARD[2].Input)));
  AssertEquals('MemTransform3', ParseBytes(DATA_MEMTRANSFORM_STANDARD[3].Expected), LHasher.MemTransform3( ParseBytes(DATA_MEMTRANSFORM_STANDARD[3].Input)));
  AssertEquals('MemTransform4', ParseBytes(DATA_MEMTRANSFORM_STANDARD[4].Expected), LHasher.MemTransform4( ParseBytes(DATA_MEMTRANSFORM_STANDARD[4].Input)));
  AssertEquals('MemTransform5', ParseBytes(DATA_MEMTRANSFORM_STANDARD[5].Expected), LHasher.MemTransform5( ParseBytes(DATA_MEMTRANSFORM_STANDARD[5].Input)));
  AssertEquals('MemTransform6', ParseBytes(DATA_MEMTRANSFORM_STANDARD[6].Expected), LHasher.MemTransform6( ParseBytes(DATA_MEMTRANSFORM_STANDARD[6].Input)));
  AssertEquals('MemTransform7', ParseBytes(DATA_MEMTRANSFORM_STANDARD[7].Expected), LHasher.MemTransform7( ParseBytes(DATA_MEMTRANSFORM_STANDARD[7].Input)));
  AssertEquals('MemTransform8', ParseBytes(DATA_MEMTRANSFORM_STANDARD[8].Expected), LHasher.MemTransform8( ParseBytes(DATA_MEMTRANSFORM_STANDARD[8].Input)));
end;

procedure TRandomHashTest.MemTransform1;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform1, DATA_MEMTRANSFORM1);
end;

procedure TRandomHashTest.MemTransform2;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform2, DATA_MEMTRANSFORM2);
end;

procedure TRandomHashTest.MemTransform3;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform3, DATA_MEMTRANSFORM3);
end;

procedure TRandomHashTest.MemTransform4;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform4, DATA_MEMTRANSFORM4);
end;

procedure TRandomHashTest.MemTransform5;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform5, DATA_MEMTRANSFORM5);
end;

procedure TRandomHashTest.MemTransform6;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform6, DATA_MEMTRANSFORM6);
end;

procedure TRandomHashTest.MemTransform7;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform7, DATA_MEMTRANSFORM7);
end;

procedure TRandomHashTest.MemTransform8;
var
  LHasher : TRandomHash;
  LDisposables : TDisposables;
begin
  LHasher := LDisposables.AddObject( TRandomHash.Create ) as TRandomHash;
  TestMemTransform(LHasher.MemTransform8, DATA_MEMTRANSFORM8);
end;

procedure TRandomHashTest.TestMemTransform(ATransform : TTransformProc; const ATestData : array of TTestItem<Integer, String>);
var
  LCase : TTestItem<Integer, String>;
  LInput : TBytes;
begin
  for LCase in ATestData do begin
    LInput := TArrayTool<byte>.Copy(ParseBytes(DATA_BYTES), 0, LCase.Input);
    AssertEquals(Hex2Bytes(LCase.Expected), ATransform(LInput));
  end;
end;

initialization

{$IFDEF FPC}
  RegisterTest(TRandomHashTest);
{$ELSE}
  RegisterTest(TTestRandomHash.Suite);
{$ENDIF FPC}

end.
