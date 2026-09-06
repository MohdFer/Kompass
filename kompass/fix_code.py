import os
import re

replacements = {
    r'AppTextStyles\.h1': 'AppTextStyles.displayLarge',
    r'AppTextStyles\.h2': 'AppTextStyles.displayMedium',
    r'AppTextStyles\.h3': 'AppTextStyles.headlineLarge',
    r'AppTextStyles\.h4': 'AppTextStyles.headlineMedium',
    r'AppTextStyles\.h5': 'AppTextStyles.bodyLarge',
    r'AppTextStyles\.h6': 'AppTextStyles.bodyMedium',
    r'AppTextStyles\.bodyText': 'AppTextStyles.bodyMedium',
    r'AppTextStyles\.labelSmall': 'AppTextStyles.labelMedium',
    r'AppTextStyles\.subtitle1': 'AppTextStyles.labelLarge',
    r'AppTextStyles\.subtitle2': 'AppTextStyles.labelMedium',
    r'AppColors\.primary\b': 'AppColors.primaryGold',
    r'AppColors\.secondary\b': 'AppColors.secondaryTeal',
    r'AppColors\.accent\b': 'AppColors.accentRed',
    r'AppColors\.border\b': 'AppColors.sandDark',
    r'AppColors\.surfaceVariant\b': 'AppColors.surfaceVariant', # Correct
    r'text:\s*': 'label: ', # Be careful with this one
}

# specific button replace to be safer
button_pattern = r'KompassButton\(\s*text:'
button_repl = r'KompassButton(label:'

lib_dir = 'lib'
files_changed = 0

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for pattern, repl in replacements.items():
                if pattern == r'text:\s*':
                    continue # skip generic
                new_content = re.sub(pattern, repl, new_content)
            
            new_content = re.sub(button_pattern, button_repl, new_content)
            
            # Additional fixes
            new_content = new_content.replace('KompassCard(child:', 'KompassCard(') # Fix KompassCard missing required named parameter child
            # Wait, KompassCard *does* take a named parameter child. So KompassCard(child: is correct!
            # What was the error? "The named parameter 'child' is required, but there's no corresponding argument" in tour_list_screen.dart:30
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                files_changed += 1

print(f"Fixed {files_changed} files.")
