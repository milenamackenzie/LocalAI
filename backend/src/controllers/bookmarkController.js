const bookmarkRepository = require('../repositories/bookmarkRepository');

exports.addBookmark = async (req, res, next) => {
    try {
        const { itemId, itemType, itemTitle, itemCategory, itemScore, itemImageUrl } = req.body;
        await bookmarkRepository.addBookmark({
            userId: req.user.id,
            itemId,
            itemType,
            itemTitle,
            itemCategory,
            itemScore,
            itemImageUrl
        });
        res.status(201).json({ success: true, message: 'Bookmark added' });
    } catch (err) {
        next(err);
    }
};

exports.removeBookmark = async (req, res, next) => {
    try {
        const { id } = req.params; // itemId
        await bookmarkRepository.removeBookmark(req.user.id, id);
        res.status(200).json({ success: true, message: 'Bookmark removed' });
    } catch (err) {
        next(err);
    }
};

exports.getBookmarks = async (req, res, next) => {
    try {
        const bookmarks = await bookmarkRepository.getBookmarks(req.user.id);
        res.status(200).json({ 
            success: true, 
            data: bookmarks.map(b => ({
                id: b.item_id,
                title: b.item_title,
                category: b.item_category,
                score: b.item_score,
                imageUrl: b.item_image_url,
                isBookmarked: true
            }))
        });
    } catch (err) {
        next(err);
    }
};
