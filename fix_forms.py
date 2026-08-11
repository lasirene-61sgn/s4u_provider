import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    content = f.read()

# Replace specific Row(crossAxisAlignment: ...) with _ResponsiveRow(isMobile: _isMobile, crossAxisAlignment: ...)
# Actually _ResponsiveRow doesn't take crossAxisAlignment currently, I'll ignore it or update it.
# Let's just update the _ResponsiveRow to accept crossAxisAlignment. No, I hardcoded it to CrossAxisAlignment.start.
# It's fine for forms.

content = re.sub(
    r'Row\(\s*children: \[\s*Expanded\(child: _bankField',
    r'_ResponsiveRow(isMobile: _isMobile, children: [ Expanded(child: _bankField',
    content
)

content = re.sub(
    r'Row\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[\s*Expanded\(child: _bankField',
    r'_ResponsiveRow(isMobile: _isMobile, children: [ Expanded(child: _bankField',
    content
)

content = re.sub(
    r'Row\(\s*children: \[\s*Expanded\(child: _statusDropdown',
    r'_ResponsiveRow(isMobile: _isMobile, children: [ Expanded(child: _statusDropdown',
    content
)

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(content)

