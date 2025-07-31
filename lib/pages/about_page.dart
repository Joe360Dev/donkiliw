import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  static const routeName = '/about';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appName = '';
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _version = packageInfo.version;
    });
  }

  Future<void> _launchEmail() async {
    final l10n = AppLocalizations.of(context)!;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'joe360dev@gmail.com',
      queryParameters: {'subject': 'Support pour $_appName'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text(
            l10n.unableToOpenMailClient,
            style: textTheme.titleMedium!.copyWith(
              color: colorScheme.surface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.error),
          showIcon: true,
          primaryColor: colorScheme.inversePrimary,
          backgroundColor: colorScheme.inverseSurface,
          foregroundColor: colorScheme.inversePrimary,
          closeOnClick: true,
          pauseOnHover: true,
          dragToClose: true,
          closeButton: ToastCloseButton(
            showType: CloseButtonShowType.none,
          ),
          autoCloseDuration: Duration(seconds: 2),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          defaultSize * .75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: defaultSize * .5,
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: defaultSize * 3.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    _appName.isNotEmpty ? _appName : l10n.appName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    height: defaultSize * .25,
                  ),
                  Text(
                    l10n.versionNumber(_version),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: defaultSize * .75,
            ),
            Text(
              l10n.description,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            Text(
              l10n.appDescription(_appName),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: defaultSize * .75,
            ),
            Text(
              l10n.developer,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            Text(
              'Joe360Dev',
              style: GoogleFonts.notoSans().copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Text(
              l10n.developerDescription,
            ),
            SizedBox(
              height: defaultSize * .75,
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            Text(
              l10n.supports,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            Text(
              l10n.supportsDescription,
            ),
            SizedBox(
              height: defaultSize * .75,
            ),
            Text(
              l10n.contact,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            GestureDetector(
              onTap: _launchEmail,
              child: const Text(
                'joe360dev@gmail.com',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(
              height: defaultSize * .5,
            ),
            Text(
              l10n.contactDescription,
            ),
          ],
        ),
      ),
    );
  }
}
