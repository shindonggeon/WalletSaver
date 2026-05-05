import os
import glob
import re

base_dir = r"c:\Users\sdg03\OneDrive\바탕 화면\WalletSaver\figma_reference\wallet_saver_app\lib\app\views"
for root, _, files in os.walk(base_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Fix imports based on depth
        rel_path = os.path.relpath(path, r"c:\Users\sdg03\OneDrive\바탕 화면\WalletSaver\figma_reference\wallet_saver_app\lib\app")
        parts = rel_path.split(os.sep)
        # app/views/screens/home/widgets/file.dart -> parts: ['views', 'screens', 'home', 'widgets', 'file.dart']
        depth = len(parts) - 1 # from the current file's directory back to `app`
        
        import_path = ("../" * depth) + "core/"
        data_path = ("../" * depth) + "data/"
        controllers_path = ("../" * depth) + "controllers/"
        
        # Replace occurrences of incorrect depth
        content = re.sub(r"'(\.\./)+core/", f"'{import_path}", content)
        content = re.sub(r"'(\.\./)+data/", f"'{data_path}", content)
        content = re.sub(r"'(\.\./)+controllers/", f"'{controllers_path}", content)
        
        # Token replacements
        content = content.replace("AppColors.surfaceWhite", "AppColors.white")
        content = content.replace("AppColors.mutedGray", "AppColors.bgPage")
        content = content.replace("AppTextStyles.h2", "AppTextStyles.pageTitle")
        content = content.replace("AppTextStyles.bodyText", "AppTextStyles.body")
        content = content.replace("AppTextStyles.metaText", "AppTextStyles.caption")
        content = content.replace("AppColors.safeGreen", "AppColors.stateSafe")
        content = content.replace("AppColors.dangerRed", "AppColors.expense")
        content = content.replace("AppColors.primaryPurple", "AppColors.primary")
        content = content.replace("AppColors.lightPurple", "AppColors.primaryLight")
        content = content.replace("AppColors.cardShadow", "AppColors.shadowColor")
        content = content.replace("AppColors.textSecondary", "AppColors.textHint")
        content = content.replace(".withOpacity(", ".withValues(alpha: ")
        
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
