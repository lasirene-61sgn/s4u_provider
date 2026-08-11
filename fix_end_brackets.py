import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    c = f.read()

c = c.replace(
"""              }),
            ]
          ],""",
"""              }).toList(),
            ])),
          ],"""
)

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(c)
