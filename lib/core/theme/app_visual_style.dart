enum AppVisualStyle { classic, flat, neumorphic, glass, paper }

extension AppVisualStyleLabels on AppVisualStyle {
  String get label => switch (this) {
    AppVisualStyle.classic => '经典精致',
    AppVisualStyle.flat => '现代扁平',
    AppVisualStyle.neumorphic => '柔和拟物',
    AppVisualStyle.glass => '通透玻璃',
    AppVisualStyle.paper => '静谧纸感',
  };

  String get description => switch (this) {
    AppVisualStyle.classic => '柔和投影与清晰层级，延续当前设计',
    AppVisualStyle.flat => '减少投影，用色块和边界建立层级',
    AppVisualStyle.neumorphic => '双向柔光投影，呈现轻微浮雕质感',
    AppVisualStyle.glass => '半透明表面、边缘高光与渐变背景',
    AppVisualStyle.paper => '温暖低饱和色调，像精装手帐一样安静',
  };
}
