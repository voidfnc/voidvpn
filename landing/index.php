<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>voidVPN | Private & Secure VPN Service</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Base Dark Mode Styling */
        body {
            background-color: #15202b;
            color: #ffffff;
            font-family: "Helvetica Neue", Arial, sans-serif;
            padding-top: 60px;
        }

        /* Navbar Styling */
        .navbar-inverse .navbar-inner {
            background: #15202b;
            border-bottom: 1px solid #38444d;
        }

        .navbar .nav > li > a {
            color: #ffffff;
            text-shadow: none;
        }

        .navbar .nav > li > a:hover {
            color: #1da1f2;
        }

        /* Profile Box & Tweet Styling */
        .profile-box, .tweet {
            background: #192734;
            border: 1px solid #38444d;
            border-radius: 5px;
            padding: 20px;
            margin-bottom: 20px;
            position: relative;
        }

        .profile-box h1 {
            margin: 0;
            padding: 0;
            font-size: 24px;
            line-height: 1.3;
        }

        .tweet:hover {
            background: #1d2f41;
            transition: background 0.2s ease;
        }

        .tweet-header {
            margin-bottom: 10px;
            border-bottom: 1px solid #38444d;
            padding-bottom: 5px;
        }

        .tweet-name {
            font-weight: bold;
            color: #ffffff;
        }

        .tweet-username {
            color: #8899a6;
            margin-left: 5px;
        }

        .tweet-timestamp {
            color: #8899a6;
            font-size: 12px;
            float: right;
        }

        .tweet-content {
            color: #ffffff;
            font-size: 14px;
            line-height: 1.6;
        }

        /* VPN Specific Styling */
        .pricing-box {
            background: #1d2f41;
            border: 1px solid #38444d;
            border-radius: 8px;
            padding: 25px;
            margin: 15px auto;
            text-align: center;
            transition: transform 0.3s ease;
            box-sizing: border-box;
            max-width: 600px;
        }

        .pricing-box:hover {
            transform: translateY(-5px);
        }

        .price {
            font-size: 36px;
            color: #1da1f2;
            margin: 15px 0;
        }

        .price-period {
            color: #8899a6;
            font-size: 14px;
        }

        .membership-description {
            color: #8899a6;
            margin: 20px 0;
            font-size: 14px;
            line-height: 1.6;
            padding: 0 20px;
        }

        .feature-list {
            list-style: none;
            padding: 0;
            margin: 20px auto;
            text-align: left;
            max-width: 400px;
        }

        .feature-list li {
            margin: 10px 0;
            padding-left: 25px;
            position: relative;
        }

        .feature-list li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #1da1f2;
        }

        .server-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }

        .server-location {
            background: #1d2f41;
            border: 1px solid #38444d;
            border-radius: 5px;
            padding: 15px;
            text-align: center;
        }

        .action-button {
            background: #1da1f2;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            max-width: 200px;
            margin: 20px auto 0;
            transition: background 0.2s ease;
            display: block;
        }

        .action-button:hover {
            background: #1991db;
        }

        .certification-badge {
            display: inline-block;
            background: #1da1f2;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin: 2px 5px;
        }

        .feature-icon {
            font-size: 24px;
            color: #1da1f2;
            margin-bottom: 10px;
        }

        .footer {
            border-top: 1px solid #38444d;
            padding: 20px 0;
            color: #8899a6;
            text-align: center;
            margin-top: 20px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .pricing-box {
                margin: 15px;
                padding: 20px;
            }
            .server-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
            .membership-description {
                padding: 0 10px;
            }
            .feature-list {
                padding: 0 10px;
            }
        }
    </style>
</head>
<body>
    <div class="navbar navbar-inverse navbar-fixed-top">
        <div class="navbar-inner">
            <div class="container">
                <a class="brand" href="#">voidVPN</a>
                <div class="nav-collapse collapse">
                    <ul class="nav">
                        <li><a href="#features">Features</a></li>
                        <li><a href="#pricing">Membership</a></li>
                        <li><a href="#locations">Locations</a></li>
                        <li><a href="#security">Security</a></li>
                        <li><a href="#signup">Join</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="profile-box" id="features">
            <div class="row">
                <div class="span12">
                    <h1>Welcome to voidVPN</h1>
                    <div class="profile-info">
                        Privacy-First VPN Service | No-Logs Policy<br>
                        <span class="certification-badge">AES-256 Encryption</span>
                        <span class="certification-badge">No-Logs Policy</span>
                        <span class="certification-badge">Kill Switch</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="tweet">
            <div class="tweet-header">
                <span class="tweet-name">Why Choose voidVPN?</span>
                <span class="tweet-username">@voidfnc</span>
                <span class="tweet-timestamp">2025-05-19 21:23:16 UTC</span>
            </div>
            <div class="tweet-content">
                <div class="row">
                    <div class="span4">
                        <div class="feature-icon">🔒</div>
                        <h4>Complete Privacy</h4>
                        <p>Military-grade encryption with strict no-logs policy</p>
                    </div>
                    <div class="span4">
                        <div class="feature-icon">⚡</div>
                        <h4>Lightning Fast</h4>
                        <p>Optimized servers for streaming and gaming</p>
                    </div>
                    <div class="span4">
                        <div class="feature-icon">🌍</div>
                        <h4>Global Access</h4>
                        <p>Servers in 50+ countries worldwide</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="tweet" id="pricing">
            <div class="tweet-header">
                <span class="tweet-name">Membership Model</span>
                <span class="tweet-username">@voidfnc</span>
                <span class="tweet-timestamp">2025-05-19 21:23:16 UTC</span>
            </div>
            <div class="tweet-content">
                <div class="pricing-box">
                    <h3>Invitation-Only Access</h3>
                    <div class="price">FREE<span class="price-period"> forever</span></div>
                    <div class="membership-description">
                        <p>voidVPN is an exclusive, invitation-only service committed to maintaining the highest standards of privacy and security.</p>
                    </div>
                    <ul class="feature-list">
                        <li>Completely Free Service</li>
                        <li>Unlimited Bandwidth</li>
                        <li>Access to All Servers</li>
                        <li>Premium Security Features</li>
                        <li>24/7 Priority Support</li>
                        <li>Invitation Required to Join</li>
                    </ul>
                    <button class="action-button">Request Invitation</button>
                </div>
            </div>
        </div>

        <div class="tweet" id="locations">
            <div class="tweet-header">
                <span class="tweet-name">Server Locations</span>
                <span class="tweet-username">@voidfnc</span>
                <span class="tweet-timestamp">2025-05-19 21:23:16 UTC</span>
            </div>
            <div class="tweet-content">
                <div class="server-grid">
                    <div class="server-location">🇺🇸 United States</div>
                    <div class="server-location">🇬🇧 United Kingdom</div>
                    <div class="server-location">🇩🇪 Germany</div>
                    <div class="server-location">🇯🇵 Japan</div>
                    <div class="server-location">🇸🇬 Singapore</div>
                    <div class="server-location">🇨🇦 Canada</div>
                    <div class="server-location">🇳🇱 Netherlands</div>
                    <div class="server-location">🇫🇷 France</div>
                </div>
            </div>
        </div>

        <div class="tweet" id="security">
            <div class="tweet-header">
                <span class="tweet-name">Security Features</span>
                <span class="tweet-username">@voidfnc</span>
                <span class="tweet-timestamp">2025-05-19 21:23:16 UTC</span>
            </div>
            <div class="tweet-content">
                <div class="row">
                    <div class="span6">
                        <h4>🛡️ Core Security</h4>
                        <ul class="feature-list">
                            <li>AES-256 encryption</li>
                            <li>Automatic kill switch</li>
                            <li>DNS leak protection</li>
                            <li>Perfect forward secrecy</li>
                        </ul>
                    </div>
                    <div class="span6">
                        <h4>🔐 Privacy Features</h4>
                        <ul class="feature-list">
                            <li>No-logs policy</li>
                            <li>Anonymous sign-up</li>
                            <li>Cryptocurrency payments</li>
                            <li>Multi-hop connections</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="tweet" id="signup">
            <div class="tweet-header">
                <span class="tweet-name">Join voidVPN</span>
                <span class="tweet-username">@voidfnc</span>
                <span class="tweet-timestamp">2025-05-19 21:23:16 UTC</span>
            </div>
            <div class="tweet-content">
                <p>voidVPN is a free, invitation-only VPN service focused on providing maximum privacy and security to our community members.</p>
                <h4>How to Join:</h4>
                <ul class="feature-list">
                    <li>Request an invitation through our secure form</li>
                    <li>Await verification and approval</li>
                    <li>Receive your personal invitation code</li>
                    <li>Create your account and enjoy free, secure VPN access</li>
                </ul>
                <button class="action-button">Request Invitation</button>
            </div>
        </div>

        <footer class="footer">
            <p>© 2025 voidVPN • Last Updated: 2025-05-19 21:23:16 UTC</p>
        </footer>
    </div>

    <script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>
    <script>
        // Security Features
        document.addEventListener('DOMContentLoaded', function() {
            // Disable right click
            document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                return false;
            });

            // Disable keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if(e.key === "F12" || 
                   (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                   (e.ctrlKey && e.shiftKey && e.key === 'J') ||
                   (e.ctrlKey && e.key === 'u')) {
                    e.preventDefault();
                    return false;
                }
            });

            // Custom right-click message
            document.onmousedown = function(e) {
                if(e.button === 2) {
                    alert('Right clicking is disabled on this website.');
                    return false;
                }
            };

            // Update timestamps
            updateTimestamps();
        });

        // Timestamp update function
        function updateTimestamps() {
            const now = new Date();
            const utcString = now.toISOString().replace('T', ' ').slice(0, 19) + ' UTC';
            
            document.querySelectorAll('.tweet-timestamp').forEach(timestamp => {
                timestamp.textContent = utcString;
            });

            document.querySelector('.footer p').textContent = 
                `© ${now.getFullYear()} voidVPN • Last Updated: ${utcString}`;
        }
    </script>
</body>
</html>
