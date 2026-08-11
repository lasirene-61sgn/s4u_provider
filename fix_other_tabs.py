import re

with open('lib/screens/provider_info/ui/provider_info_screen.dart', 'r') as f:
    c = f.read()

# 1. Review List
c = c.replace(
"""            else ...[
              // Table Header
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Row(""",
"""            else _ResponsiveTableWrapper(isMobile: _isMobile, child: Column(children: [
              // Table Header
              if (!_isMobile) Container(
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Row("""
)
c = c.replace(
"""                      Expanded(child: Text(review['createdAt']?.toString().split('T').first ?? '', style: const TextStyle(fontSize: 13, color: AppColors.primaryDark))),
                    ],
                  ),
                );
              }).toList(),
            ],""",
"""                      Expanded(child: Text(review['createdAt']?.toString().split('T').first ?? '', style: const TextStyle(fontSize: 13, color: AppColors.primaryDark))),
                    ],
                  ),
                );
              }).toList(),
            ])),"""
)

# 2. Commission List
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

# 3. Handyman List
# Handyman actually uses `// Table Header` or `// Table`? Let's check using grep.
