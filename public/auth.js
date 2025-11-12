/**
 * Authentication utilities for RentRead frontend
 */

class AuthManager {
    constructor() {
        this.token = localStorage.getItem('token');
        this.user = null;
        this.isAuthenticated = false;
    }

    // Check if user is authenticated
    async checkAuth() {
        const token = localStorage.getItem('token');
        if (!token) {
            this.logout();
            return false;
        }

        try {
            const response = await fetch('/api/auth/verify', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            if (response.ok) {
                const data = await response.json();
                this.user = data.user;
                this.isAuthenticated = true;
                this.token = token;
                return true;
            } else {
                this.logout();
                return false;
            }
        } catch (error) {
            console.error('Auth check failed:', error);
            // Don't logout on network errors, just return false
            return false;
        }
    }

    // Get current user profile
    async getUserProfile() {
        if (!this.isAuthenticated) {
            throw new Error('Not authenticated');
        }

        try {
            const response = await fetch('/api/auth/profile', {
                headers: {
                    'Authorization': `Bearer ${this.token}`
                }
            });

            if (response.ok) {
                const userData = await response.json();
                this.user = userData;
                return userData;
            } else {
                throw new Error('Failed to fetch profile');
            }
        } catch (error) {
            console.error('Profile fetch failed:', error);
            throw error;
        }
    }

    // Logout user
    logout() {
        localStorage.removeItem('token');
        localStorage.removeItem('userEmail');
        localStorage.removeItem('rememberMe');
        this.token = null;
        this.user = null;
        this.isAuthenticated = false;
    }

    // Login user (store token)
    login(token, email) {
        localStorage.setItem('token', token);
        localStorage.setItem('userEmail', email);
        this.token = token;
    }

    // Get authorization header for API requests
    getAuthHeader() {
        if (!this.token) {
            return {};
        }
        return {
            'Authorization': `Bearer ${this.token}`
        };
    }

    // Redirect to login if not authenticated
    requireAuth() {
        if (!this.isAuthenticated && !localStorage.getItem('token')) {
            window.location.href = 'signin.html';
            return false;
        }
        return true;
    }

    // Redirect authenticated users away from auth pages
    redirectIfAuthenticated() {
        if (this.isAuthenticated || localStorage.getItem('token')) {
            window.location.href = 'dashboard.html';
            return true;
        }
        return false;
    }
}

// Create global auth manager instance
const authManager = new AuthManager();

// Helper functions
function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        z-index: 1000;
        animation: slideIn 0.3s ease-out;
    `;
    
    // Set background color based on type
    switch (type) {
        case 'success':
            notification.style.backgroundColor = '#10b981';
            break;
        case 'error':
            notification.style.backgroundColor = '#ef4444';
            break;
        case 'warning':
            notification.style.backgroundColor = '#f59e0b';
            break;
        default:
            notification.style.backgroundColor = '#3b82f6';
    }
    
    // Add animation styles
    if (!document.querySelector('#notification-styles')) {
        const style = document.createElement('style');
        style.id = 'notification-styles';
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    }
    
    document.body.appendChild(notification);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 5000);
}

// API helper for authenticated requests
async function apiRequest(url, options = {}) {
    const headers = {
        'Content-Type': 'application/json',
        ...authManager.getAuthHeader(),
        ...options.headers
    };

    const response = await fetch(url, {
        ...options,
        headers
    });

    if (response.status === 401) {
        authManager.logout();
        window.location.href = 'signin.html';
        throw new Error('Authentication required');
    }

    return response;
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { authManager, showNotification, apiRequest, formatDate };
}