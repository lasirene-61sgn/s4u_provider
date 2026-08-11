import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    c = f.read()

c = c.replace(
"""                  // Table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF635BFF),""",
"""                  // Table
                  _ResponsiveTableWrapper(isMobile: _isMobile, child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isMobile) Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF635BFF),"""
)

# Also we need to close the _ResponsiveTableWrapper after the Container.
# Let's find the end of Bank List Table.
# The table ends before:
#                   const SizedBox(height: 24),
#                   Row(
#                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
#                     children: [
#                       const Text('Showing 1 to 10 of 10 entries'
# Or similar pagination. Let's look for `)).toList(),\n                      ],\n                    ),`

c = c.replace(
"""                            ),
                          )).toList(),
                      ],
                    ),
                  ),""",
"""                            ),
                          )).toList(),
                      ],
                    ),
                  )),"""
)

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'w') as f:
    f.write(c)

