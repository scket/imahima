# imahima

## memo
### 2019/12/11 shota takeshima
#### 進捗
- TinderUIの実装
  - [Koloda](https://github.com/Yalantis/Koloda)を利用
- チャット機能の実装
  - [MessageKit](https://github.com/MessageKit/MessageKit)を利用

### 2019/11/24 shota takeshima
#### やったこと
- TabBarControllerの追加
  - 一旦、「メイン」「チャット」「マイページ」を下部のタブで選択可能にした
  - 実装の都合上ストーリーボードとVCが1:1にはならない
  - Splash→Main→Mainの中でVCが分岐(ここではRootVCを経由していない)
  - https://github.com/scket/imahima/pull/1

### 2019/11/20 shota takeshima
#### やったこと
- ログイン周りの動きを確認
- Main.storyboardにUIStackViewを利用して、デバイスごとに均等に表示されるよう制約を追加
- 遷移で[UINavigationController](https://qiita.com/ryu1_f/items/4a0e452e94c9ba609220)を使うのがデフォルトっぽいので調査中
  - 横からスライド、モーダルっぽく遷移が実現できるはず

### 2019/11/20 yuki goto
#### やったこと
- LogoutViewControllerのlogoutコールバックからLoginViewControllerへ遷移させるようにした
- Splash -> Login -> Main -> Logout -> Login -> Main -> Logtout -> Login・・・ のループができることを確認した
- LoginViewControllerにAPIを叩いてUserDefaultsにユーザ情報を保存するロジックが入っていたのでServiceクラスに分離した

### 2019/11/19 yuki goto
#### やったこと
- FBLoginButton()の挙動がおかしかったので改めて[公式のドキュメント](https://developers.facebook.com/docs/swift)見直した
- AppDelegateの↓２つのfunctionでFBSDKをinitializeする必要があるとのこと
  - ```func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool```
  - ```func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool```
- ↑の修正によってログイン/ログアウトがAccessTokenのnil?と同じ表示になることが確認できた
- LogoutViewControllerとか作ったけど```LoginButtonDelegate```のクラスはcallback必須ぽいのでひとつにまとめればいいかな
- Logout後の遷移はまだ書いてない

### 2019/11/09 shota takeshima
#### やったこと
- 画像ファイル系をassets以下に移動
  - `Assets.xacassets`以下でimageを管理するっぽい
- SplashVCのグルグルが出てこないのが気になる(まだ直せてない)
- RootVC経由の初期遷移でMainに行かないように修正
  - infoの設定を修正する必要があった
  - LoginVCとMainVCに遷移できるようになったが、画面が真っ暗で表示されちゃう(調査中)
  

### 2019/11/07 yuki goto
#### やったこと
- RootViewControllerをいれてみた
- LoginVCのlabelが表示されず？見た目ではsplash -> main のような挙動
- log仕込んでみたらちゃんとLoginVCはsplashから遷移しているぽい
- MainVCのインスタンスをとっていない(transitionToMain()を呼んでいない)はずなのにMianVCのviewDidLoad()が走ってる
- Main.storyboardが特別扱いぽいのでHomeに名前変えてみたらMainがありませんって怒られる．．．
- 常にRootVCでviewを管理したいのに，Main.storyboardのviewが前にきてる感じする

### 11/6 オフライン
#### 次までにやること
- RootViewControllerの概念を使う
  - [ここ](https://qiita.com/Riscait/items/29e34d922dad834106da)をほぼコピペしてきて大元を作る
- ↑でいうところのRootVCとSplachVC以外はStoryBoardと1対1の関係にViewControllerが配置される

### 2019/11/05 yuki goto
#### やったこと
- LaunchScreenが表示されたなかったので試行錯誤
- なんかよく分からんがstoryboard消して作り直したらできたので適当にロゴ画像追加しといた
- storyboardのdebugほんとにキツそうなので使いたくない
- 調べるとやっぱりコンフリクトしたりdebugキツかったり煩雑な処理書きづらかったりでstoryboard使わない派もけっこういるみたい
- そんな工数かからなさそうだったらstoryboard消したい

### 2019/11/04 shota takeshima
#### やったこと
- 起動手順
  - rootで`pod install`
  - `***(プロジェクト名).xcworkspace`が出来上がるので、それをXcodeで開いてビルドする
- segueの調査(ログイン後に画面遷移しない問題)
  - エラー文を見ると、swiftのライフサイクルの途中で画面遷移しているのがいけなさそう
  - `viewDidAppear`で画面遷移を実行させるべきって書いてあったのでいじってみたけど同じエラーがでちゃう…
    - [swift初心者:画面推移時の「whose view is not in the window hierarchy!」の対処方法](https://qiita.com/Atsushi_/items/604db81a87930d57d50b)
    - ただ、ログイン状態をチェックしてログインしてれば`SecondViewController`に遷移はできる

### 2019/11/03 yuki goto
#### やったこと
  - ライブラリ管理に[CocoaPods](https://qiita.com/satoken0417/items/479bcdf91cff2634ffb1)使った
  - swift5のdocument見ないとfacebookのライブラリの差分でかすぎて死ぬのでswift5でぐぐるべし
  - FacebookLoginは[ここのページ](https://qiita.com/haru15komekome/items/8f63a6273103489503a3)をほぼコピペしたので参考に
- やれなかったこと
  - [segue](https://qiita.com/misakiagata/items/b7f6c2f6c9f988ec38c7)は連結できてると思うんだけど，なんかSecondViewControllerで情報とれてない？
    - ViewControllerでは名前とかとれてる(ViewControllerのl99-l102)
    - 試しにSecondViewControllerにLabelはったら表示されてるのでsegueの問題ではなさそう
    - と思ったけどMain.storyboardにSecondViewControllerのoutletと紐付けしたら画像と名前とアドレス表示できた
    - Facebookログインはこれで一通り完成
