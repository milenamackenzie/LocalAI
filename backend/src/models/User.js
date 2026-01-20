const bcrypt = require('bcrypt');

class User {
    constructor(data) {
        this.id = data.id;
        this.username = data.username;
        this.email = data.email;
        this.passwordHash = data.password_hash || data.passwordHash;
        this.role = data.role || 'user';
        this.isVerified = !!data.is_verified;
        this.failedLoginAttempts = data.failed_login_attempts || 0;
        this.lockoutUntil = data.lockout_until ? new Date(data.lockout_until) : null;
        this.verificationToken = data.verification_token;
        this.avatarUrl = data.avatar_url;
        this.deletedAt = data.deleted_at;
        this.createdAt = data.created_at;
        this.updatedAt = data.updated_at;
    }

    async verifyPassword(password) {
        if (!this.passwordHash) return false;
        return bcrypt.compare(password, this.passwordHash);
    }

    isLocked() {
        return this.lockoutUntil && this.lockoutUntil > new Date();
    }

    toJSON() {
        return {
            id: this.id,
            username: this.username,
            email: this.email,
            role: this.role,
            isVerified: this.isVerified,
            avatarUrl: this.avatarUrl,
            createdAt: this.createdAt
        };
    }
}

module.exports = User;
