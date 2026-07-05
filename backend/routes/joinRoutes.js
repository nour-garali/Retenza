const express = require('express');
const Commerce = require('../models/Commerce');
const QRCode = require('../models/QRCode');
const ScanHistory = require('../models/ScanHistory');
const asyncHandler = require('../utils/asyncHandler');

const router = express.Router();

/**
 * @swagger
 * /api/join/{merchantCode}:
 *   get:
 *     summary: Résoudre un QR code par merchantCode
 *     description: Endpoint public appelé quand un client scanne un QR Code. Retourne les infos du commerce.
 *     tags: [Join]
 *     parameters:
 *       - in: path
 *         name: merchantCode
 *         required: true
 *         schema:
 *           type: string
 *         example: M482931
 *     responses:
 *       200:
 *         description: Commerce trouvé
 *       404:
 *         description: QR Code invalide ou commerce introuvable
 */
router.get('/:merchantCode', asyncHandler(async (req, res) => {
  const { merchantCode } = req.params;

  // Chercher le commerce via merchantCode
  const commerce = await Commerce.findOne({ merchantCode, status: 'active' })
    .select('name category logo contact loyaltyProgram merchantCode');

  if (!commerce) {
    return res.status(404).json({
      success: false,
      message: 'QR Code invalide — aucun commerce partenaire trouvé.',
    });
  }

  // Récupérer les infos du QR Code
  const qrCode = await QRCode.findOne({ commerce: commerce._id, isActive: true });
  if (!qrCode) {
    return res.status(404).json({
      success: false,
      message: 'QR Code inactif ou invalide.',
    });
  }

  // Enregistrer le scan anonyme pour statistiques
  await ScanHistory.create({
    qrCode: qrCode._id,
    commerce: commerce._id,
    scannedAt: new Date(),
  }).catch(() => {}); // Ne pas bloquer en cas d'erreur

  // Incrémenter le compteur de scans
  await QRCode.findByIdAndUpdate(qrCode._id, {
    $inc: { scanCount: 1 },
    lastScannedAt: new Date(),
  });

  res.json({
    success: true,
    data: {
      commerce: {
        id: commerce._id,
        name: commerce.name,
        category: commerce.category,
        logo: commerce.logo,
        merchantCode: commerce.merchantCode,
        loyaltyProgram: commerce.loyaltyProgram,
      },
      qrCode: qrCode.code,
    },
  });
}));

module.exports = router;
