import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    content = f.read()

# Add _isMobile property
content = re.sub(r'class _ProviderInfoScreenState extends ConsumerState<ProviderInfoScreen> \{',
                 'class _ProviderInfoScreenState extends ConsumerState<ProviderInfoScreen> {\n  bool get _isMobile => MediaQuery.of(context).size.width < 800;\n',
                 content)

# Remove local const bool isMobile = true;
content = re.sub(r'const bool isMobile = true;\n', '', content)

# Write back
with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(content)

