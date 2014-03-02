


;;MyStyleという名前のカスタムスタイルを作る
;;ノウハウ蓄積用
<style name="MyStyle" parent="android:Theme.Holo">
    <item name="android:layout_width">fill_parent</item>
    <item name="android:layout_height">wrap_content</item>
	<item name="android:actionBarStyle">@style/my_actionbar_style</item>
    <item name="android:actionBarTabBarStyle">@style/my_actionbar_tabbar_style</item>
    <item name="android:actionBarTabStyle">@style/my_actionbar_tab_style</item>
</style>

;;アクションバー部分の色変更
<style name="my_actionbar_style" parent="@android:style/Widget.Holo.ActionBar">
    <item name="android:background">#ffffaaaa</item>
</style>

;;タブ部分の色変更。tabbar_style,tab_styleがあり紛らわしいが、こちらはタブ全体の背景を指定できる
<style name="my_actionbar_tabbar_style" parent="@android:style/Widget.Holo.ActionBar.TabBar">
 <item name="android:background">#ffffaaaa</item>
</style>

;;タブ部分の色変更。選択時や、タブ下部の色など変えたい場合はdrawableをカスタムする
<style name="my_actionbar_tab_style" parent="@android:style/Widget.Holo.ActionBar.TabView">
        <item name="android:background">@drawable/tab_indicator_holo</item>

 <item name="android:background">#ff0000aa</item>
</style>



;;中央が範囲可変の、左右になにか置きたい場合のレイアウト
;;layout_weight=1を中央のViewに設定してあるのが重要
;;o<-->o
<LinearLayout
        android:layout_width="fill_parent"
        android:layout_height="fill_parent" >

        <Button
            android:id="@+id/button1"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Button" />

        <LinearLayout
            android:layout_width="fill_parent"
            android:layout_height="match_parent"
            android:layout_weight="1" >

        </LinearLayout>

        <Button
            android:id="@+id/button2"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Button" />

    </LinearLayout>
