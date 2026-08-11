import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    c = f.read()

# Fix isMobile -> _isMobile in overview tab
c = c.replace('EdgeInsets.all(isMobile ? 16 : 24)', 'EdgeInsets.all(_isMobile ? 16 : 24)')
c = c.replace('if (isMobile)', 'if (_isMobile)')

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(c)
