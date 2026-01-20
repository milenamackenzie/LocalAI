const interactionRepository = require('../repositories/interactionRepository');
const logger = require('../utils/logger');

exports.logInteraction = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { interactionType, itemId, itemType, data } = req.body;

    const id = await interactionRepository.logInteraction({
      userId,
      interactionType,
      itemId,
      itemType,
      data
    });

    logger.info(`Interaction logged: ${userId} -> ${interactionType} on ${itemId}`);

    res.status(201).json({
      success: true,
      message: 'Interaction logged',
      data: { id }
    });
  } catch (err) {
    next(err);
  }
};
