import 'dart:io';

void main() {
  final baseDir = Directory('lib/app/views');
  if (!baseDir.existsSync()) return;

  final files = baseDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Normalize path separators to forward slash for calculation
    String path = file.path.replaceAll('\\', '/');
    List<String> parts = path.split('/');
    
    // lib/app/views/screens/home/widgets/file.dart -> parts: ['lib', 'app', 'views', 'screens', 'home', 'widgets', 'file.dart']
    int appIndex = parts.indexOf('app');
    if (appIndex == -1) continue;
    
    int depth = parts.length - appIndex - 2; 
    
    // If depth is 3, prefix = '../../../'
    String prefix = '../' * depth;
    String importCore = "'${prefix}core/";
    String importData = "'${prefix}data/";
    String importControllers = "'${prefix}controllers/";
    
    // Replace imports dynamically
    content = content.replaceAll(RegExp(r"'(\.\./)+core/"), importCore);
    content = content.replaceAll(RegExp(r"'(\.\./)+data/"), importData);
    content = content.replaceAll(RegExp(r"'(\.\./)+controllers/"), importControllers);
    
    // Replace variables
    content = content.replaceAll('AppColors.surfaceWhite', 'AppColors.white');
    content = content.replaceAll('AppColors.mutedGray', 'AppColors.bgPage');
    content = content.replaceAll('AppTextStyles.h2', 'AppTextStyles.pageTitle');
    content = content.replaceAll('AppTextStyles.bodyText', 'AppTextStyles.body');
    content = content.replaceAll('AppTextStyles.metaText', 'AppTextStyles.caption');
    content = content.replaceAll('AppColors.safeGreen', 'AppColors.stateSafe');
    content = content.replaceAll('AppColors.dangerRed', 'AppColors.expense');
    content = content.replaceAll('AppColors.primaryPurple', 'AppColors.primary');
    content = content.replaceAll('AppColors.lightPurple', 'AppColors.primaryLight');
    content = content.replaceAll('AppColors.cardShadow', 'AppColors.shadowColor');
    content = content.replaceAll('AppColors.textSecondary', 'AppColors.textHint');
    
    content = content.replaceAll('.withOpacity(', '.withValues(alpha: ');
    
    file.writeAsStringSync(content);
  }
  print('Dart script finished!');
}
