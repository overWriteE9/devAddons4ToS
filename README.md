# devAddons4ToS
アドオン開発 for ToS

## つかいかた
各区分けの中のIPFフォルダに「xxxxx_crypted.ipf」が入ってるので、それらをDLして  
「_xxxxx-☃-vX.X.ipf」に名前を変えてToSクライアントを終了させてから  
ToSのdataフォルダ(addonフォルダではない)に突っ込んで、ToS起動

「xxxxx_crypted.ipf」がないなら「_xxxxx-☃-vX.X.ipf」があると思うので  
それをToSのdataフォルダ(addonフォルダではない)に突っ込んで、ToS起動するだけ

**注意**
Tosのaddonsフォルダに、アドオン名小文字(TBLEWだったら tblew )のフォルダを作らないと  
settings.jsonが保存されないので、起動するたびに位置調整しなくちゃならない  
(addonManagerはインストール時にこの作業をやってくれてる)

***

### TBLEW (TBL enemy who?)
TBLの中で敵の情報を見るとき、「F4」おしてTBLのアイコン押して  
観戦ページ選んで、更新ボタン押すのダルくない？  
ってのを改善したっぽいやつ。(ただし自動では読み込まない)

1. */tew posset* でフレームを表示して、TBL中に表示されていい場所にドラッグする
2. */tew posfix* で位置を確定させる
3. チャットマクロ(チャット定型文)に */tew reload* を入れて、すぐに呼び出せるようにしておく
4. TBLに参加する
5. TBLのマップに移動したら、チャットマクロ(*/tew reload*)を2回か3回実行する  
(ゲームリストの更新は通信が発生するので、あまりやりすぎるとラグる)
6. フレームに相手の情報とかが表示されたりされなかったりする

* */tew* ・・・ヘルプ
* */tew show* ・・・フレーム表示
* */tew hide* ・・・フレーム消す
* */tew enable* ・・・アドオン有効化
* */tew disable* ・・・アドオン無効化
* */tew alpha 数字* ・・・フレーム表示透過度を指定(標準は20％、つまり80％の濃さで表示されてる)

***

### zoomyplus for TBL
3on3のTBLが実装されて、縮小表示して画面一望できる！と思いきやzoomy入れてるとできないことが発覚  
zoomyのアドオンをいちいちdataフォルダから消して、一般MAPでは元に戻すってのがメンドかったので  
TBLではzoomy自体を読み込まないようにしたのがこれ。他はzoomyplusとまったく一緒。

***
