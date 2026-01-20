const bcrypt = require('bcrypt');

class User {
    constructor(data) {
        this.id = data.id;
        this.username = data.username;
        this.email = data.email;
        this.passwordHash = data.password_hash || data.passwordHash;
        this.role = data.role || 'user';
        this.createdAt = data.created_at;
        this.updatedAt = data.updated_at;
    }

    /**
     * Verify provided password against stored hash
     * @param {string} password 
     * @returns {Promise<boolean>}
     */
    async verifyPassword(password) {
        if (!this.passwordHash) return false;
        return bcrypt.compare(password, this.passwordHash);
    }

    /**
     * Return safe JSON representation (no password)
     */
    toJSON() {
        return {
            id: this.id,
            username: this.username,
            email: this.email,
            role: this.role,
            createdAt: this.createdAt,
            updatedAt: this.updatedAt
        };
    }

    static async hashPassword(password) {
        return bcrypt.hash(password, 10);
    }
}

module.exports = User;
