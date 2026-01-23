class Interaction {
    constructor(data) {
        this.id = data.id;
        this.userId = data.user_id;
        this.interactionType = data.interaction_type;
        this.itemId = data.item_id;
        this.itemType = data.item_type;
        this.data = typeof data.interaction_data === 'string' 
            ? JSON.parse(data.interaction_data || '{}') 
            : data.interaction_data;
        this.createdAt = data.created_at;
    }

    isValid() {
        const validTypes = ['view', 'click', 'like', 'dismiss', 'search', 'bookmark', 'share'];
        const validItems = ['place', 'event', 'article', 'ad'];
        
        if (!validTypes.includes(this.interactionType)) return false;
        if (!validItems.includes(this.itemType)) return false;
        if (!this.itemId) return false;
        
        return true;
    }

    toDB() {
        return {
            user_id: this.userId,
            interaction_type: this.interactionType,
            item_id: this.itemId,
            item_type: this.itemType,
            interaction_data: JSON.stringify(this.data)
        };
    }
}

module.exports = Interaction;
