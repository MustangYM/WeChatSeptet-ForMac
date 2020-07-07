<p align="center">
<img src="https://github.com/MustangYM/WeChatExtensionSources/blob/master/Pictures/wechatSeptetFace.png" width="1000px"/>
</p>

- 因为完整版[WeChatExtension](https://github.com/MustangYM/WeChatExtension-ForMac)过于臃肿，且大部分用户只会用到少部分核心功能(包括我自己)，所以开发了简版的小助手WeChatSeptet。
- 简版可以多开，但不支持打开小程序。

## 安装效果
<p align="center">
<img src="https://github.com/MustangYM/WeChatExtensionSources/blob/master/Pictures/WeChatSeptetFuntion.png" width="800px"/>
</p>

## 简版特色功能，多开时使用不同主题
- 多开了微信A与微信B，假设此时都是`黑夜模式`。
- 在微信B中选择`少女模式`，微信B自动退出。
- 在微信A中点击多开，登录微信B，即可实现两个微信使用不同的皮肤。
<p align="center">
<img src="https://github.com/MustangYM/WeChatExtensionSources/blob/master/Pictures/differentTheme.png" width="800px"/>
</p>

## 怎么安装？
- 如果你已经安装过WeChatExtension, 那么请先卸载。如果安装后打开微信闪退，重新安装微信(并不会丢失聊天记录)再安装小助手。
- 确保你的电脑有安装Git，如果没有安装Git，执行`brew install git`可安装Git。
- 安装
```
sudo rm -r -f WeChatSeptet-ForMac && git clone https://github.com/MustangYM/WeChatSeptet-ForMac.git && cd WeChatSeptet-ForMac/WeChatSeptet && ./install.sh
```
- 卸载
```
sudo rm -r -f WeChatSeptet-ForMac && git clone https://github.com/MustangYM/WeChatSeptet-ForMac.git && cd WeChatSeptet-ForMac/WeChatSeptet && ./uninstall.sh
```
## 手动安装
与WeChatExtension的手动安装方式一样。下载本项目到电脑上，cd到WeChatSeptet文件夹，将install.sh文件拖入终端工具中回车执行即可。

## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/mustangym666#backer)]

<a href="https://opencollective.com/mustangym666#backers" target="_blank"><img src="https://opencollective.com/mustangym666/backers.svg?width=890"></a>

## License

MIT license. 

## 交流与支持

QQ群 741941325

## 免责声明

本项目遵循MIT协议，方便交流与学习，包括但不限于本项目的衍生品都禁止在损害WeChat官方利益情况下进行盈利。如果您发现本项目有侵犯您的知识产权，请与我取得联系，我会及时修改或删除。
