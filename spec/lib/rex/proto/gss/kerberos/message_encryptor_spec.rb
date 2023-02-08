# -*- coding:binary -*-
require 'spec_helper'
require 'rex/text'

RSpec.describe Rex::Proto::Gss::Kerberos::MessageEncryptor do
  let(:aes_key) do
    key = Rex::Proto::Kerberos::Model::EncryptionKey.new
    key.type = Rex::Proto::Kerberos::Crypto::Encryption::AES256
    key.value = ['721aca0c50d9e8b848034c516f7662b9f388b44cc52b511e72353916263c51c5'].pack('H*')

    key
  end

  let(:server_seq) do
    1754559103
  end

  let(:client_seq) do
    1754679412
  end

  subject(:initiator_encryptor) do
    described_class.new(aes_key, client_seq, server_seq, is_initiator: true)
  end

  subject(:acceptor_encryptor) do
    described_class.new(aes_key, server_seq, client_seq, is_initiator: false)
  end

  subject(:acceptor_encryptor_no_subkey) do
    described_class.new(aes_key, server_seq, client_seq, is_initiator: false, use_acceptor_subkey: false)
  end

  context 'When we are the initiator' do
   it 'The header is correct' do
     encrypted, pad_len = initiator_encryptor.encrypt_and_increment('abcd')
     header = encrypted.slice(0..16)
     tok_id, flags, filler, ec, rrc, snd_seq = header.unpack('nCCnnQ>')
     expect(tok_id).to eq(0x0504)
     expect(flags).to eq(6)
     expect(filler).to eq(0xFF)
     expect(snd_seq).to eq(client_seq)
   end

   it 'Decrypts a real value' do
     ciphertext = ['050407ff0000001c000000006894727f1c178884b1fc2143fc6297dc343243423e5657e727867e6a05697d11f85e2e593af1c4f536d190cb4fd85b87a95a5bf2ddfc5b80cbb29d6bfae2ef6efbdbef8cb0955ced2a40969082d65d5746c4c33c110cdf5dfd63dc46dfbe79439f69292b4d4dd6e357fc7600690157932c97291ff02b341dca4b1e9cdccf9ab566496fd0528a8796f9f942756c7abd6e57d652173009231da1ca07868e2244c97db90646f80115cb7dad982787b419053a995f052b6dab9187007df5d2c61c78101049a3a26417f26adea556b8c824314c179a3f4d241a9b02ddd3d542bfbafac364c26e6b27701039f46ba505e0df8c8cbc7387036c8bb62f4c5a5c8183e63ac0827756a5a32c83b4dd1793918b9e09a0198a335fc7bc844480ec5df297146d0dbc11b5806ac20accfaa7ea63f9035da3ae5a6091ec2a637334a8be9b38cb1a66158adbbd41fdc54d8f0c02805b5c6cd368b40d33be55375d4faea78bd52b7bbb2517bcaec864cc8fca5b67ea43e5da3d300654eeb8d03a1a944403eb6a1bfea08b46a4e7f273c3590cddfff24cfe835456d12fa8d8cc61eeb737d48345807959a1659519dfd6ba739450644f909bf6c0f3f41a15e7623c6024913467a87d2502e79a2d1d6c61119111fccde10298bea663d29a432f5bc2fb52833552cc876802a6d3d1003dc855625dd3af55bb114d7129900f2281c57111b5c7fb36ba6acf29eceb3a74311561f14849143b5e56aa217666e135a8d32cb36b5e803cc31ffb25c3833f120893d2a430469ed6a35d32322892776b84745659053315556a754b69a595e4213365b72a5d63e77f0b31d370e4d45b4668862f1b717e80e7cc873c9640cbe3b01c6a3c5edce4fb10ad11dc1f310b972795bb9b44f667bae9367cc8dab40fcc4fd69fac0cbed11a1ac6e42e9370a364f42d5530899dd901b2a813489cb1f0df59e9d05dfdeeb192e103c6da9e8b7697337b135c06a8ebd02b6f553955d7a77ad383ef0703fd7bb0e3a6c39041baff073228fc4ab23b10ab8a537038dab8d78bd087aeccf9ac3e02f9c1198436f379a739bdfb6e622a9e5cf85491df39aca959fbeacfd80de00063b640c80dcb1f615fb8f1653cf0542c08670d2592429c161e44f5c6cd32614bc0f6741b43425030d84ba9b680c7c855606f86b56ff746607fab0a01dbff87c2ef5bcaef6c208a7cb0a4c3ebf171dbca78b5b26bf573ba162f693752d48e2cdcaac7e1f6d45688db377402ed493fc28b657c5ba46969c4dcb9a6e4336abe3d93dc6a2ca282c463c00f92867404f4e7887efaad4c60cf80a9e2d61e127a715a768e76509995b42d8b7bc016c0672a658b419cf8986b8dde5b6c1fe3fb8deb009ab60d35e33c95e8c6209ff4a01897b8e8303ea9f617cbab5a7f0905a5a8ac845b400dac76b64cc38e0ec9bcc7236da5363380d2117f42928d01ff52e26e5e4689b7d77a6f14a32c7104d7c78cd0234026c1caabf9884bd19b737796a2d64987c05af1024e3005b23405d5733ecfc651cd2779f2d88d3915969079abfaf6fa1cb7464fb73eac55b38f266c19b5a876d1261d120504c96b0f8f414c244c2e243f9b61876d15b884f895855aec808edce9b85279691a6687bbde10ba85cf2a3b443976f10ffb17ddd1abeb70aee11edc9126b448543a384ed272cf82140fedbf3294e00da179f4de6a5c8703663848b360317cde7173a67af6ec589f84ee89f680ab9b8453890779922432f40395efe0840be9b2d45a3d8261f5fa647b3a18aff51df280545383a32764cbb0b507fcc338555a57cace08e28d71abf920f8ba35c7e63fe6d847086cc749f270edb681cfdd21a1af609e4ad64ea77fc19b47e65e284e53460e7d4bf83c40955766c4e380b9d3cd6e656fb995f91808ac37e42c68b10b9e7a2d83f086c1e7af435ac16155a9a325c67a259dfe7f654ee21717e89f5a451337461c4da60c4f34759c63e2696f9111bfcd4c1a0c3a93999e161d5896a09060f1a58a3597a4be422a7a2ff593d2c0ac39f21f91bae8589de90d150f69fe9de3fc60b1e7523019a43cb5acc0916e21259d51018962cddd846505dc060183fd1b9797bf6684ffab330958eb936548f434e70f7e9aea861703bc6a1a59244216ac95d2745059d0cc8c649f85e17d98eb3d248a67078eae73960fd70828866c9b92bbf9387d1bb2f2aa49c6a1043f2c86b4da356db79f8f550db7a20121dffeb10b2efb2251e4e20e5f0c6e58a1a2d035246a8154da09f4df2fdb61dee87803d258f275cd14619764857bb1e4b7bd6ade758070721501658a19782d9386b9decff0364594c104bc375edf5e2dc9a3687ef6490f8d7aec42547d53de24ec2750435c7b5dcb3c3fcb4a2d45d1435d9fb492b92d1255f1ca242ee17bf51786728a4af0ae3d1e83a042a1219b64a34a4306db504901e6b8aa89d46667fcd47d5b3ac44da56cff40fd91919749c49ba971daad0f82cfc0aa2c071f2df661310b7e309e2c9db7b1617f1ef7bc203367588d9ce50338bf0f19f5f05d867febf2764a9b24588d8f7c2b86e3ca012e4d8aefb868ed1c2b4a99ed1f8f7d64c956f551ec35b5e73dc01165dc453eddb95be4f9f457aace07b5574115fd0c8f6a374c5f3cbd661435b453cba645f63d5e7d1219e2486fa49153a057aec12f0a59ff5ed9507c30dfdd676b2a722caf2c2aa68b82eb7f2cf48769591575aaaa8029a1291d1e9344dcabc9364250053ac86e91a34f78ee0227d9c966e1c980d54b18ec87c1626840e25b3c48d764a6fdcd8e9cf4711f3561c1952f3527a6cf5d9bab681f0fa929b0c706925982ecad9bca90398cfa5168848b51c11395afe4b134f9edc9c61d4445fee8f4ddfa9e5ce227068b21e141adc822d698c00e769047987da59c48101490f1361ca23e1ae915307a9e116c661d313c18eb498d0202432cd8f508a0b5696f7922e8685c92bb7c687e009239ca0598f21487cbf5a8e57579212c21b8751464e040569a93c84855668316ecd253c060095294dea8324604a18d2c2f1564c3fdcfeb2f09481e91a1ed5f5ff34c4f3aa907fa67e511fb55358f61281657fc8a9f5151775d2daa05c683ce679c2b1680dbbd800336730b3d'].pack('H*')

     decrypted = initiator_encryptor.decrypt_and_verify(ciphertext)
     expect(decrypted).to start_with('<s:Envelope xml:lang="en-US" xmlns:s="http://www.w3.org/2003/05/soap-envelope"')
   end

   it 'Is reversible' do
     plaintext = Rex::Text.rand_text_alpha(rand(7000))
     encrypted, pad_len = initiator_encryptor.encrypt_and_increment(plaintext)
     decrypted = acceptor_encryptor.decrypt_and_verify(encrypted)

     expect(decrypted).to eq(plaintext)
   end
  end

  context 'When we are the acceptor' do
   it 'The header is correct' do
     encrypted, pad_len = acceptor_encryptor.encrypt_and_increment('abcd')
     header = encrypted.slice(0..16)
     tok_id, flags, filler, ec, rrc, snd_seq = header.unpack('nCCnnQ>')
     expect(tok_id).to eq(0x0504)
     expect(flags).to eq(7)
     expect(filler).to eq(0xFF)
     expect(snd_seq).to eq(server_seq)
   end

   it 'Decrypts a real value' do
     ciphertext = ['050406ff0000001c0000000068964874e5b8e098b0225db3863c0df0f4634da7d19ffdb5a9f775d6856058db58100c8706c65f325c34ab3f9334d927134c203c569d0ed867f87119ec2061829a4111d65301ca33b9aad8692b7f8993db5a58d5f95de5b0cf6ba8109fe2d03bfd29ea7e9cd2561434b1a82911200bbffdcb42ffe4f8c33cb8379237bde1f36c2f6075eba5823602e7aac2d973d6c955188e8dc6958ce1ecf7686732ac7cd311c93aa90a9f20f44da979d4ac887c04be03d4d0e607ec7bb1b73bf26da990d428adb96a3c72311a2834a32b08883dc043dd0a27f5800ae3c365bf14f6c0b69f46c80a3ee7c2607d9104460b5798cb7b011b48c0d667d36da6e918563aacbc187d4038b4f1c4b12313e8c5143930b0dc0f5be1592308965dcddf8caeaf86c286693a18dd87586b2fb893cc46c38480c5a76e172371176fc0bc19abe2cb44fa0577bf36a0199db6c0595c651967bb7cd61daf31b3a468edf1a9accba8625bff131d04f01d1b26d82239e3fde0a3a5f795c2bd09e7d3f3bbe887795b0817094ec9668fc469fe5e6f2a07e19f4a491cd0e4ff4ca8f02eb9ee1fc5518020f79735f3361e1040923c9b8146c7ffc7432b55514d6ca8c9117bb55ac3ce36e718f60e488bd798c7f461eea5bb964731a154a8f2b19d0130209b4ebd334b6988f8fec49196464d7c41e0112b957d02d066e1b16b52404dd3410b8e1005060fb85e820bac9ae95b0038aba50eff76f4772bf411dcf982798f0b1b99e8e6df537ac82269c75138bbe7bca1947cdf96689644c689a3f82adb2023b491deae69b5cb77dc5cd81aa5831cb5082aba8fc4bdedac1da2d43aa5303808e99bd60ba232ab4ddb45ea6f2ebe17caa08bc279ef236b8d554303fe3ccb645729b6f16e77729a1fb3cc2e2647cf6c0be0015acd26fd81a12ef9baa47df408ae7a1db897698a91b93bfb88baec9ee74bea3d2739744f8b6bc991bfc4291e3fa062261c3d466775ba5a46a640cfd38502260a8c18a6dfc1490857f3064e8919bc0d2c6e5834b888d06f8ef3ea3629b86f3b959dd13ce7ea30137883c27f73b59b754bf7d5f91e54a716f969cc6f16e62ffed7494106a8ae9fa81e8f2633f3ccb59c2e909d19eebf7e553a0dab752966b117249abd0c01460bf1df6f65950f33aa087340f0fbd9b87985941170a6ada7864ff4b05d8e8b13fdbab1c4f8a712bb2cd477a795d30b59978f75d94c6df345327e4a7b187c433f4848027a9cdcf0b47d679d23a8e2867fcbea84a6b482bd0ac961c6c9f52726a6b0496964cc127f2a83f19965b6d49805d152817adeba1b9641d411902cf76c8f728ef2efd9a51d864c1ded7518b29b1940dc95263ef857bb75d4e12b2950f0d2945fc3c9c372cca96fbf5f546120adea8b3e617424771df96070fc41b3eb29de6f30c5c82173bffd271d3f4be26cbaa6684f4df7ebc12a4b199a1e2ecbb3a44ff9c5c1c918578bfa3994f0332fc7e0339ac4c4ed21314464541a345afaff3ab060fe7c142449cf152f4dc0bb7a6b0869961761cafdce9e48f4be9dfac81824a53bb34a0304b6bf1af791b3d561f1c2bd0d65aa777cd0b8bafdf3e2c32347f3cc3c5ee307c0b872e1f6a7fc6985b8ced8439d0c9e6dcd8d54c76815088c9c94d29d916f86c3b405fe9f0dc1d1df01609411a551380e500ce898ef6a3811c964cb3a5cd8e266e25d7ff12014293f19b0a1691ecc322b5808dddfbadc51589c742fff7466812995a33594655308201d093d763f86270f908e1ad2df975c41a668cc99ad04d587a3d8149c6820699b05475ad173c03adcdaf3dfe4268cdfa31ac70c1ba06a2dc20bdf0d8d652d2d4e498b2947e6e7f73924348e25383bcf32c70cf5e6a0aae30e16462a84c36d46d6edf6d04e4caf8177bc93f9a8420d7e9981204bfe464511bedd3cf58c894eb0a301cde672bb802d805bffc80455d87110aa8ecbe809ce064df37e3a629210cc6819bb01770818b388f62444df6ec681e63fdcb322f643905229314ea0b439e87bd1450a8230fde87ed6a91acfb0e153f069970c7fe27b5837159ce79960bab8e1f091d4a932d3b4dfb87127d2dc810146a9e56369a72036121855b3df99c8fe3744f987075254fec351222729b75e67b9edf6fd51a091269f91d2923f1dba26d179a9ba3467ffa3f96503efa8c5616d04c592d9fc68776912b19925b7c2a2f2442b136bbd2e0dcc4e4ce2de9dcf4d790bdc19b814bad54640fad271cff7836ab448bf2e8a258d504004d21f09eced1e2870d5b1f8527331e4b8c180c865bc2681b94bea72d2b4cb051bcdb691a2e8b93123f0349fd0ac3ed9fb30412a8bd5e7c3e40357f2aa924d60c38522f66609f76bba26399f89d9d459ceb84cb6cb6c5b8c90e91e38b5bce161ffd7a5bb7e7d08e359a33c38736920ce6c69f9f53f39be521fd1b3b79dea8590aeca6f8da1840d67ad40ab3f12ac703ad79bbe56a69116a1783f8266457f21b346ba2ed1bd0aeb2d93527c2f2c458325016e42c9daf0fa2716f96ff2c6a19fa5b998aa3a3f21aa9cf28445e416efc4d8254e6bfe7d2cc8a61861716bf7711382c6e130bf2ac5a4f764103c2cf0845928c086742ab412a5cc7c95122309f9f23fe1f53ae379c8e8bf285ac7f6ae90f7c1d1bdbc274f96424d0ebe39870910f9442db28765f1daa11a094e70fc9649315d7ab4c2843542ac196f5c42690b22df75b020b688899ea647ed22a3cf0c0cfedf6591c3c1bf2f25bda09d746c8521514ea2eecfdb15ca2c431f43ab6d4cfda2f0df9e8339ca16aad73072ee1deecb3dbb01917755ed02f8519b4d93649d56d6ad1711ac6e33da2a06f9a2f859ec84605e08e562aad5a8a374778a1e4fae0fe89277ff12ff1ce242bcb4e5b95eb3e279ce8a12a882e9fa7ae55590635706dc6d6168f3dafabbdeae069c19b860c81ff802e7ad81f6e85a775c335da2bb092ba9a36170de4c9f6c0b90418f78b50d680a08f26a9c82eb81be340adf64c1a10cbb40e23db5f0c6591738a22896c56a3149ef79ca7875b1952e91931a60e021d8c9ea3b44e2b81d8eed54390e104e0a355111a725849d8d4775564ff4b46c9f9b3806e7ec8c084b76b7d1c48badfe8e5d4b5755f2de3320b4c0c16b9cca7eb609e8b07e357cb48e6009b8b13e0d426ecd87add8c75124a8bcf87abcce0459a28eb7d2399f2759a4c95c582b5a20f49797eab9e980890ac29fbd849eb4f85f8e3256892c1b4e2ace5858f92c7072623c493eb5b0c11656178c592a9452d7824f8d77e40d582d3b25707a4e1e902f5035b1a9932f7b1ffa4dc349af99dfd4c17822d88c2c77ce2ab2111ef8548e17eacba6cf5f16edfd808d9339ee42472ac3a02d5804b11935aad27f412c867af41adccd48dae4c1bf712234a1f2afb2994c37845383e022521e72f036376c2210c4e5f408e550ae1c44cddfd9a26c762e2b1a2c3b00bdfb03cc92f65ced26c20d8b9ffd8ae97d5d3f813ad8072c5dbd69a1b21e558e75ffbbe4cdd31d1a2fcda625da6b0d8ddb69865202c62fb3369c2f45bac9e3c1631840d569a85b618a7751a9a5fb6ef5c78df40fcd7c028a52be63aa36aba10cd7b86611bcfa17bfbebdf55dd75aa22be0ac4714f957ea29577ea0ce644d2450309125f435f0aa4c999b8200bce21afe868a4bacd102159b203b3c0bfe5b92f08d85f1c164e8b6d689f38d78ef47a5a01929c1b8d08f95f8b30b17270803ee123a5ca28297f8fe084b4e4b624e5d207b76d1cfce1b635cba4e3e734243730bc818ae7ea9c12445ac0280bc70def46a5ccc1b1ba7a7eab817851800659d8f2c258b2f67a10a8cb22cb98535c51d66dc683ef2b009aef03f1102cb1e157b0697c38457b716ddbe6c677dbf4bd63ee1603ce90c906c5055b28f7b421e2e18bc71503d8a66e89dffbc8a30d01add27ec978b2dde694938634f684b1f628e7cfe83bfa83da778406220431ecc769dd832565ceda06dbac9739edf5c168b0d6208544a33609665058fa968ba1c6766b2f8620a0b2a1a6d63edf7474a994bb38b6b51698ce2d3c7f61abdd7964aa08c977b2a363849dd1409b65e7e0ad258e70c4bca59c32b7116b2ae76cc0a66c91a2b5890dee0dd35f7f17f566e3390583e043804e14a5c29a93d0fd2e5cf6e048230b2b786f136b0cbbafb73d67a5562a2f3e8f6c6d27c0659bcbad1cadebbbdbfff7e3076b71e0f3d66047898c7155a502b9765b696a9a0caa2576fe7ce579856b08fcc7bc900f8f9897e15cadd9c83217680099d59ca4bafaa8b90fcc5cf849d2091ccfb6f195470d995b0f4d5587e8f01741695194d7c269dc5d4f8656a60c7c9436473819f6fd6f3c4577939a5711c7826db0b4bff75fb560d851a97d55b86e694682023a8089e8300606a7cef0f46633ebe7d7b7762ccb5a448ea3344a4e4cd6306ebd178cdc9eee493ecc2f8a334555956fe60219bf9f89d9e7b3458a39f20a1b0c887a1f6333099fc775e558d9221ade5f1f5f00a36a0116eff975ba8efc3f8961b4e03735479f604e82773fdef0b8650da13b50b37b0f7e54d9cddade8087f929b1f23f607f537474c30e0be1cedbd19643c69b8f80235404cd66108d46028488a1e428f3a9441f12fc432f8934a15e8b571cc93fd12805353ed35c5088498b8fad2cd212c7b88ddc9c94ca25e9958740158b2de2bb276940859bbb25a7d7af3f19aa18c8f9c9e8f42f26e356c52b7bced643b58d26b848f839c51e441f23bcbc0e69cdb890ca8924b260ef5049dca5d037e1db938ae88df9804b369c3c1f422246674b1887d7ea0c884c87e2cffb4eaa68af0dea5c841a56d15bfd823c93335b76db04bdda3996585dcb59d59a414a14a25bd666af031e73772d7c508183d837e4321d897901ac7107101f2d6398dacd6cf315c6f7bead9e89e5902d16b4068560ac9371cde5f19f0219064447667876f43a0d45be7db744717a6ccb4d8718d690354b8e0419cb0ca51757900367ba1a8c57eeea344409f46b98ae81a894ee3b8b7bfbe4ef0bf518af6ea33230347db39c2d60b9258fcda911763f7a44bbe45aef183aa487a26a1e395229b167eea9b3c62c686074fe157c6251c57aad3ba0a21b139ed9e355d1f82d40533314e785d4cf8b420b47180efcae31ee7b74e2d581cebe5a917de9e848347a7e2867a6043137033c7ed327d42a891d782e503a3b56e4ee87640d25e4bd6cc57602ce36d7eb728167067b56d20204cc50145f0b5f86c1ae131b615bf08221de2a0de701aa4e077442c7b6e800dbfdcfc600c80041efb37fbb9e9c241abec69b7952ccd336f7be8d333269044cff232d70945a6a199a37961d58273696a9fd71fcd3775bd5869b8d3d30de67ac6d10364b73b9ac165bffaa78cc3dfebeacdbf538289e96f09be3ce4b4813175c0dcfb4f2325fdf9e68efea502083973b81835e7553fff25dac93782e080603d419573752b2f626b2aba664711812eab97301b0091df8efdc12af4013561c60017cafbc9ee1d45b2227b44bac0642f23095a7f4abd47610292ce02285e13cb9c01c7521d1d92518ad389febe2a55bfaf2011f2dfdb5de59986faffb122881ccaa20c72c6fe93d8545e3ee0a0f9a6b4a4910bc31c9d55ad3ae2e4f3d894b6e52814829e26d0fe8c09c76758a19cfb522469fbfeaa277f41cb5c63a79fd20ef3f821b631644aded68153459e6b5c5cef29831c96c6e35faa6435a7c9fe276c43b0f332d36a40e7a6688d735e12e5462285b6eaa24b79c464f0602c81a68c5bebe4a7946e42929c5108d080e660ca40a15276ba44c710758efa697eba63aa1aa6c218e55f317040fbbca7354ea267eac365a97867323bd2ae9db7ef70f52d62665ccd07d89d9a4fd91a79ae0a88e6f8fb28c47ab92e4fb62c3e66951f1a6d543fc76215af58c0994763cb77dcf44ee5654a9f2ddeb9313c75900470666819f7826a9f00d8aac873aba3e05a83d22e3f6810cc4681fbb972ded64a76bf4f3f1f29b02c24e90e1d541f8862f94feecc6c5d99925dcff6517ca974b45fddaf5abd72de4def0d111cd3504c1b45e8f7f280e7f52f637356110563d7b7af894339e5b52a97d2fd91ead062120474c8d1e854a5a98a4d53c188e56f42fee1ecd41269604d7a64a79bcb58bcba2ab30136bc5c6eee2fe8d0059133ce108eaf921acdd399374f1cc5c770ca1a65f31881c91a644cf21557d976e649b40b5f99490cc73cef1008c3d9a98153534229e79d149695cbc53b92a557c754cb8bf7463f35b99f60380b801b66633fd2de15ce043a639c05a700824ee05e7ecc91657034de71bfa0c06fce6201e85e44584fdf641fde252478323f4b93b83b6cae353d22b58f888668afbed70f7b7c8bb89f9c1bfdb556e4d53175688b52fc592816985673073e5cf0ec24b24c15f65677ba4757a6c3a8843b39fb3edd980f45f3d6814401886752a97fc01164c59493c8b5fb8ef4c083e0855717b818fd5b37239d0c5703c4aa9f59a59e205aa28f9a510466a7eede40b3cfc0fd6e605315c0142c2e3a1878aa8d467f8328aabb17a52002cd03773913656240c9b524c64fc8de3081c27420f75e0e5ba3c7488c17d67924d78668923d974f934c9a75681c9cdfa0a899ebff3569cebf0cd109abbff0abd94d708f8763d573deba5d0603514ccc10085df17cf84181c5d0df426c7c10ceeae642dc0ee10ac997daa82d6f13bc676644a5f5b2ebac87961d23f6d066817d02bb2d43b09f11864152c77e3d54db935b6ad4f2b6c1f4edbdff08afa383b5f173686b443c78067c4f5149bb338870db7a2b18d7f080732f511899c53724dfa7c77b0562a89ece43d594c40d42695c5b3d3e990474321c30049198af8b6a85faf825ef22e0f0f8b238cffecb74e58ef6a7a1478912e1bc67d4c2f085949978f1391c3ce7e3d9e694c21979226c1491d355c402066f06f86301ff5ad5b21dafe90ab7204c1588ffd4c9e913f0549f5171738b80036340d9c9f24cb23133811d681a1de4f3fe3943a8213f62baccfd066117f50a7fb5385ab1b5a2a8d689df53889e0b53935857a4f416ad02a083cc2fb0796011f585a523a2a4a3b6e3a12049859999e448e3623df1ca27ab6510f040ec97b0c360af9fe6dd873597a2edd58782e27c53a7a42dd347fee9a897c544e1439d0f788fe4b29536be3c6b1419ca6c6b267d69ceb428b27c4a13e721ba6b3fc1d058c95e1e96fd0f6f08caa4e24bc375664b41661a934419a3398c97b9d232eaea515501de5d09e39d209e05f56f477589eb787fba4524c5177582e825cd6cd1bd583e5644d89b1ee40f12f929e7ae091d3277d1d33a2c76218bf51430c813987bdea8208e11cbd020464ab42df5884f74e25b54f096f5f1f7dec8061bad6e5a4d916797d35f472f6a8142f3d58af94b0ae4990db5369cd7deea25e3eb2b75468c5eb8ab6fe238317cb058e3f5f10b5510caa3efa3feee3547c0438772ba66839c2e0ae004c3f570603fdaa12fe22c20ee3ebebac0a3580a6e924e1869417966da3b03e01de10e54e4b50b1adf461edbe64f7f6ad7e3f816389fd2199002a8438f25101938e0b779cc57e18f5ec58609672d02bb8943c6343e16f5b03160e2c85a38c47897ea88a5a4f9d345344861270b060b284ec36336333e4118accf79fb98b8ffc51aa59c3127d51caf28f0c0d794bf9b94f330836e9e1ffb39737e3ac3249a050fb6920ab48b11e537c1e9ef5e9c1a00e353802b83ceaf31eba79f672c46026499d4ba653b9031135264fccbee28d8b14bbc14375a84e0b8db474e643d74e2696c9f2baf55437ede2edc46d8dba6d496cc1acd4e51ae91391794279593b9ebf3e05baf8452ca71587dd9e56ba674ca5e6266d23be77df2663ba2d03999c35ba27022bfb345314e5c0f95d2d8f855c98f30a94b4818138d9952ada1b0a0ea3963d75deb608c98b59d82cb8475b05d0cdeddfaf4358f7cecad2f05c1b4a3313c9bd615b228b073268b1ae7ceff0d3ded3638e85606d3c62ba0ccb06df5f34927579002895195d16f71db43fafb4b06c8bc26f8952a424d9bf750c2ae6bc1acd8fcc8ac4e38835915d694b93ca4aca6ac8c44c263ae26b593c2248ccd9ec571f7a8a2ab7a85fdfc76e6499795ccdc78591a6259bd0e863dc8b62e0b035e137092874a5f5d32f96e154856f225c271fafcc928a0aeaae313f71310ee66ec338688affd4ada16a8221c6fcd5e594952df3f10e90e15523e60f5a37357b0f02f6ce1f848b4a4a87de9f6a9743ab8d8030b9d82a560454476fb6c1b8e42529adaf4190261221b1c9ba37f33f0a9f4919d5c5c99c087bcfb3c2d2318e24ffa0ed2948254ff5e46256b511a783a63071063e397e6a501d04081a1ca95f3b2c309e82af52acc0da3d049ae3bba05b00f9c7ebcd98b7c77d8a2e961155babf7f09a04f6066ad5fa7fc262381cdbdb63b933e30028355e849f470232525fb7b7b25aa69017c56a91db0aa22c29c9536bb4ea100231f1688f365691b2ccf1d49435ca29491a333586d51f714b16dd639a14de8868d9e086caf93034e471b120fc5b18cc6f26ac707cd6ad6aab69b8c2b0e92270585deb8fb8ff86d2a510141f0d22bd41b1efbe51cdc734b11e87d4ad216d076553171a9246d3fc8f81612163e8f68823dcad10e4e33c040e6f843d2c4908529ee6ad6961773f8d9a2f365ad0f044c0079ba38cea42e693d42ebe40da69d4d57d82cf1c8ce7144b675e5438dc5a9bbbcb899c77b9bf5c48544d28edc8347d28991b3b7499959716a6803cb0800264d53b5de1763ec999fe89d014e5ab893c793415610b91cb7efe2c975d80a1df7003bfcb2558d2c8870b00cd68737fe39e3eef9533a0af3f3787fea42629259780f67e2ac648d1089b9945282656cd71ccb5a7ec54a25d69634cb116374e6d20a851508b2f9d743c613b1f9bec2559e851af6d29dac5ee6e07b136518987c21b2e243e2686c528a2ebf7e85603b67ca4ea9b2e62e79ea50795946aa02d9e73cafda6057af0a92627186297860db51afbaae65a5e5adc8c4f984992b73430842ad0b738b017ed59a07c6622f03835bf148c9eefc0de93fe4308914af2895aa31280176c294e56a94819fef45519c101bfef500060c308572967e49015899c4f5d3fc9f398ae5fea7398ef642ed067214bfa708c378da65dd4a427eb44954a854641c5772af8794ccfc97e77c77a8ab4c42a60c08339c18b11910be5cafa38db99208c0786072a0fd6e8742be375930da963744dd50355a2170470ce19c957976e7c53186b764906a7ff535960ce2961d3f51fab71ed3a4e255e25ffb8c42530058aeb8d13bb98367650b67cdb234081c2afe0d22acb5290e3d33e5a772f6798daeae26ad7653574e946d0e0396957ce6a3d4968f10dfccb63a1d957fc501fe7c07858c5c974b610435e0f9e2d603edd84053bfbb6858335baf604be0e971c5d64cbeb5a4452ca6b0f96d93d5e6b6c841a6d6e13577fef799c560a7a0de960b1779868312bc14d2666f1ebbc76f4a0ae788fcf6de2f954dc2aed4d5b1be4e25ba7a79b8348c13d69a9156d7765da6047403e2fee7258662d47e172fd5bb1cc203e2cda845c4471707c7be8af58386a02eb8d6673d0b012ee8dd3baf2634be540dcd882b0595bc6d8fa7e2c8173079bf32bac8de7f38b4cff0d066d1a0aea9a8f5a13561a67f71bb7147f40953063386667dd5f6931cd2b3690ac60da060a9ea9816032cf450728767e3322ddbab1ccf43060f3873d90d772ac2f00121831a2beef2af8f4cd135cd01f87c7b1587fbc1328e6b44dabb2bbebf0219f67dfc413ecd95472689ea54139d95faaef793d69768c06034ed445fb78ed777858ab0196ea1747f328af9140b45a61ac91dd05270f7d8d2a19c23200c974c466e9df7987e53d97bcdad1caa82d9bada2251f772f2bc4e8db612eac79154873798e6c7c4b0bf465574225250130fb6afd4c5346efcf8ae0058c3f6d97095fcff921aa1b4a1e4f46ade9203d11dd3945d04946e79b9c1a1a43352e9b668bfefbda741f799ef9dffee5132e81ad04bee42216d895019ecebe9e539fbbd6c7398a22550b3edbfb11e0d026f4a914a6f0d2a4da6ef21bdd20f22dc948bf34fbd30cea8f6dca0f2ae9e8c2b94f9c51059b02750580564e0fb9688780f6c226b9da99de2a8d2744d02c9c12f97f7eb545569736817e26e0b27ec2e0b70cc3b899e07d6e05113bd23de47e8b62318ce08df38cfc4b91b842a12e8c1085577a2d28ffe7765fdf119bfe60bd86ea0a7c0d07ffed29faeb1572e79e3dca7f874981519fc611a39b05acd92c107cfa0b25ed5e8772a2960fc80e6e72bafd526c99bb4841d367aeec4bd0036e89e16b32023895b6e8d54e37af33fe305e939e8cdf59e63be497e6fbe1b6ea149565f2fdb455fd24eaec614361d62f8de8b0274d3bc45550ed39eec31b722173a4a7e607bf671f83455327da11a447af869569690ab28d475cd5d5ed084092d57867c71130fdf88124c90e90e13bbc545f6a494917ba8dfa15f98999403b8a02acca6d34200e4b3bd1108900b371772d1f25838dc5c73c3daea039efc6387a1990022f96929c67aabbeb00f6fd325c2bd925ff9dcfbe2363a901be4cb4db0687bf1caf75ed216b655a905aedc6ea695d1f740195ccd20fe763c8e2657d3741e84e716ecd08eaf3ca687aa89967bb0264dda5b9def3e3f6cbdb5e6eb9d252891197eb002e982c6bcd899b690374ad8a9d12cf977fd65caaa9a38bd58a77523a25bc169dda9f40563ae5868fd5ca10d5c7dcb61943ce433329becc2d12733f1fa86d08a22c7c61b0a32cfd4d6a67a97e0e8433235c10e36d97e808a05060b54ebbcaba56d3a4b6095c11a3bd31dad130a62d2f05e7c74caa30ea385b5013500a20396b690d401f95c1d46c5a5df3d9811dc6a42ddd4b048afed1b497ff44c72a9d4cde58af99f9ce11a816bb2671a7aab73d6e76268d2b9b0dae254e76fff23c98326de1d40bf599a7392febd0ab3cb088320e448afed8cad37c3efa110e6405502b6bf0129e77ad3a44e8e226b90f0ecf6cd5689187f4f46ece8bc59170411edbdb0af4c731a522ee8cf63bc565357419e7ceb03c26dafc8c6004a66407229cf9da153b6dd973085e1f3c61099e27f05eaa76a6a313ca1e8621695c458fa1d49d1624dbb813b6b9bef5c50cef2bf31b'].pack('H*')

     decrypted = acceptor_encryptor.decrypt_and_verify(ciphertext)
     expect(decrypted).to start_with('<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"')
   end

   it 'Is reversible' do
     plaintext = Rex::Text.rand_text_alpha(rand(7000))
     encrypted, pad_len = acceptor_encryptor.encrypt_and_increment(plaintext)
     decrypted = initiator_encryptor.decrypt_and_verify(encrypted)

     expect(decrypted).to eq(plaintext)
   end
  end

  context 'When we are the acceptor without using subkey' do
   it 'The header is correct' do
     encrypted, pad_len = acceptor_encryptor_no_subkey.encrypt_and_increment('abcd')
     header = encrypted.slice(0..16)
     tok_id, flags, filler, ec, rrc, snd_seq = header.unpack('nCCnnQ>')
     expect(tok_id).to eq(0x0504)
     expect(flags).to eq(3)
     expect(filler).to eq(0xFF)
     expect(snd_seq).to eq(server_seq)
   end
  end
end