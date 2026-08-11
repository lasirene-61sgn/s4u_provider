import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    c = f.read()

# 1. Address List
c = c.replace(
"""            else ...[
              // Table Header""",
"""            else _ResponsiveTableWrapper(isMobile: _isMobile, child: Column(children: [
              // Table Header"""
)
c = c.replace(
"""                    ],
                  ),
                );
              }).toList(),
            ],""",
"""                    ],
                  ),
                );
              }).toList(),
            ])),"""
)

# 2. Document List
c = c.replace(
"""            else ...[
              // Table Header""",
"""            else _ResponsiveTableWrapper(isMobile: _isMobile, child: Column(children: [
              // Table Header"""
)
# Note: Document list ending is similar to Address list:
#                 );
#               }).toList(),
#             ],
# The above replace will hit both Document and Address if they are identical!
# Let's use re.sub for safety, or just do it block by block.

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(c)

