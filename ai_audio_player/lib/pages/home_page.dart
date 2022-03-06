import 'package:ai_audio_player/models/radio.dart';
import 'package:alan_voice/alan_callback.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import '../utils/ai_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  late Color _selectedColor;
  bool _isPlaying = true;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadio();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      print("audioPlayer if se pehle event ${event} ");
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  fetchRadio() async {
    var key = "assets/radio.json";
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[2];
    // print("fetchRadio fun _selectedRadio ${_selectedRadio} ");
    // _selectedColor = Color(int.tryParse(_selectedRadio.color));
    print(radios);
    setState(() {});
  }

  setupAlan() {
    AlanVoice.addButton(
        "c910005a8aac82c0f015ccfee5593b832e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) {
      print(
          "setupAlan wala function ha usme command kia arhi ha ---> ${command.data}  <---");
      _handleCommand(command.data);
    });
  }

  _handleCommand(Map<String, dynamic> response) {
    _selectedRadio = radios[2];
    // switch(response["Command"]){
    //   case "play":
    //     print("playing case ha yeh ${_selectedRadio.url}");
    //     _playRadio(_selectedRadio.url);
    //     break;
    //   default:
    //     print("command is playing in default case ${response["command"]}} ");
    //     break;
    // }
    if (response["command"] == "play") {
      print("playing case ha yeh ${_selectedRadio}");
      _playRadio(_selectedRadio.url);
    }else{
      print("command is playing in Else case ${response["command"]}} ");
    }
  }

  _playRadio(String url) {
    print("_playing FUnction m arha ha url ${url}");
    _audioPlayer.play(url);
    _selectedRadio = radios.where((element) => element.url == url) as MyRadio;
    print("_playingFun SelectedRadio ${_selectedRadio}");
    print("selected Radio Zain naam kia arha ha ${_selectedRadio.name}");
    print("selected Radio selectedRadioUrl ${_selectedRadio.name}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(colors: [
                AIColors.primaryColor2,
                AIColors.primaryColor1,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight))
              .make(),
          AppBar(
            title: "AI Music Player"
                .text
                .xl4
                .bold
                .white
                .size(10)
                .make()
                .shimmer(
                    primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                            child: ZStack([
                      Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                            child:
                                rad.category.text.uppercase.white.make().px16(),
                          )
                              .height(40.0)
                              .black
                              .alignCenter
                              .withRounded(value: 10.0)
                              .make()),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack(
                          [
                            rad.name.text.xl3.white.bold.make(),
                            5.heightBox,
                            rad.tagline.text.sm.white.semiBold.make()
                          ],
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: [
                          const Icon(
                            CupertinoIcons.play_circle,
                            color: Colors.white,
                          ),
                          10.heightBox,
                          "Double tap to play".text.gray300.make(),
                        ].vStack(),
                      ),
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .border(color: Colors.black, width: 5.0)
                        .withRounded(value: 60.0)
                        .make()
                        .onInkDoubleTap(() {
                      print("double tap wala btn ${rad.url} ");
                      print("DoubleTap fun fm ka name ${rad.name}");
                      _playRadio(rad.url);
                    }).p16();
                    // .centered();
                  }).centered()
              : const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "playing now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                print("onTap wala function jisey on n off huga ");
                if (_isPlaying) {
                  print("isplaying nahi hu rha $_isPlaying");
                  _audioPlayer.stop();
                } else {
                  print("isplaying hu rha ha ya  $_isPlaying");
                  _playRadio(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12.0)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
