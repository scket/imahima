# imahima

## memo
### 2019/11/03 yuki goto
- やったこと
  - ライブラリ管理に[CocoaPods](https://qiita.com/satoken0417/items/479bcdf91cff2634ffb1)使った
  - swift5のdocument見ないとfacebookのライブラリの差分でかすぎて死ぬのでswift5でぐぐるべし
  - FacebookLoginは[ここのページ](https://qiita.com/haru15komekome/items/8f63a6273103489503a3)をほぼコピペしたので参考に
- やれなかったこと
  - [segue](https://qiita.com/misakiagata/items/b7f6c2f6c9f988ec38c7)は連結できてると思うんだけど，なんかSecondViewControllerで情報とれてない？
    - ViewControllerでは名前とかとれてる(ViewControllerのl99-l102)
    - 試しにSecondViewControllerにLabelはったら表示されてるのでsegueの問題ではなさそう
    - と思ったけどMain.storyboardにSecondViewControllerのoutletと紐付けしたら画像と名前とアドレス表示できた
    - Facebookログインはこれで一通り完成
  
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
