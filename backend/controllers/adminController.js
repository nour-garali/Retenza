const crypto = require('crypto');
const Commerce = require('../models/Commerce');
const Client = require('../models/Client');
const User = require('../models/User');
const LoyaltyTransaction = require('../models/LoyaltyTransaction');
const ScanHistory = require('../models/ScanHistory');
const QRCode = require('../models/QRCode');
const SupportRequest = require('../models/SupportRequest');
const Incident = require('../models/Incident');
const asyncHandler = require('../utils/asyncHandler');

// ─── Gérer commerces ───────────────────────────────────────────────

exports.listAllCommerces = asyncHandler(async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;
  const filter = {};
  if (status) filter.status = status;

  const skip = (Number(page) - 1) * Number(limit);
  const [commerces, total] = await Promise.all([
    Commerce.find(filter)
      .populate('merchant', 'firstName lastName email phone isActive')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit)),
    Commerce.countDocuments(filter),
  ]);

  res.json({
    success: true,
    data: {
      commerces,
      pagination: { total, page: Number(page), limit: Number(limit) },
    },
  });
});

exports.inviteMerchant = asyncHandler(async (req, res) => {
  const { email, firstName, lastName, phone, commerceName, category } = req.body;

  const existing = await User.findOne({ email });
  if (existing) {
    return res.status(409).json({ success: false, message: 'Email already registered' });
  }

  const tempPassword = crypto.randomBytes(8).toString('hex');

  const merchant = await User.create({
    email,
    password: tempPassword,
    firstName,
    lastName,
    phone,
    role: 'merchant',
  });

  const commerce = await Commerce.create({
    name: commerceName,
    category,
    merchant: merchant._id,
    status: 'pending',
    contact: { email, phone },
  });

  merchant.commerce = commerce._id;
  await merchant.save();

  res.status(201).json({
    success: true,
    message: 'Merchant invited successfully',
    data: {
      merchant: {
        id: merchant._id,
        email: merchant.email,
        firstName: merchant.firstName,
        lastName: merchant.lastName,
        commerce: commerce._id,
      },
      commerce: { id: commerce._id, name: commerce.name, status: commerce.status },
      invite: {
        tempPassword,
        note: 'In production, credentials would be sent by email.',
      },
    },
  });
});

exports.listMerchants = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, isActive } = req.query;
  const filter = { role: 'merchant' };
  if (isActive !== undefined) filter.isActive = isActive === 'true';

  const skip = (Number(page) - 1) * Number(limit);
  const [merchants, total] = await Promise.all([
    User.find(filter)
      .select('-password')
      .populate('commerce', 'name category status')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit)),
    User.countDocuments(filter),
  ]);

  res.json({
    success: true,
    data: { merchants, pagination: { total, page: Number(page), limit: Number(limit) } },
  });
});

exports.updateMerchant = asyncHandler(async (req, res) => {
  const merchant = await User.findOne({ _id: req.params.id, role: 'merchant' });

  if (!merchant) {
    return res.status(404).json({ success: false, message: 'Merchant not found' });
  }

  const { firstName, lastName, phone, email, commerceName, category } = req.body;

  if (firstName) merchant.firstName = firstName;
  if (lastName) merchant.lastName = lastName;
  if (phone) merchant.phone = phone;
  if (email) merchant.email = email;
  await merchant.save();

  if (merchant.commerce && (commerceName || category)) {
    const commerce = await Commerce.findById(merchant.commerce);
    if (commerce) {
      if (commerceName) commerce.name = commerceName;
      if (category) commerce.category = category;
      await commerce.save();
    }
  }

  const updated = await User.findById(merchant._id)
    .select('-password')
    .populate('commerce', 'name category status');

  res.json({
    success: true,
    message: 'Merchant updated successfully',
    data: { merchant: updated },
  });
});

exports.suspendMerchant = asyncHandler(async (req, res) => {
  const merchant = await User.findOne({ _id: req.params.id, role: 'merchant' });

  if (!merchant) {
    return res.status(404).json({ success: false, message: 'Merchant not found' });
  }

  merchant.isActive = false;
  await merchant.save();

  if (merchant.commerce) {
    await Commerce.findByIdAndUpdate(merchant.commerce, { status: 'suspended' });
  }

  res.json({
    success: true,
    message: 'Merchant and commerce suspended',
    data: { merchantId: merchant._id, isActive: false },
  });
});

exports.activateCommerce = asyncHandler(async (req, res) => {
  const commerce = await Commerce.findById(req.params.id);

  if (!commerce) {
    return res.status(404).json({ success: false, message: 'Commerce not found' });
  }

  // ── Générer le merchantCode si absent ───────────────────────
  if (!commerce.merchantCode) {
    let code, exists;
    do {
      // Format : M + 6 chiffres aléatoires, ex: M482931
      code = 'M' + Math.floor(100000 + Math.random() * 900000).toString();
      exists = await Commerce.findOne({ merchantCode: code });
    } while (exists);

    commerce.merchantCode = code;
  }

  commerce.status = 'active';
  await commerce.save();

  // ── Créer / mettre à jour le QR Code ─────────────────────────
  const qrUrl = `https://retenza.app/join/${commerce.merchantCode}`;
  await QRCode.findOneAndUpdate(
    { commerce: commerce._id },
    {
      commerce: commerce._id,
      code: commerce.merchantCode,
      url: qrUrl,
      isActive: true,
    },
    { upsert: true, new: true }
  );

  // ── Activer le compte du commerçant ──────────────────────────
  await User.findByIdAndUpdate(commerce.merchant, { isActive: true });

  res.json({
    success: true,
    message: 'Commerce activated and QR code generated',
    data: {
      commerce,
      qrCode: { code: commerce.merchantCode, url: qrUrl },
    },
  });
});

exports.suspendCommerce = asyncHandler(async (req, res) => {
  const commerce = await Commerce.findByIdAndUpdate(
    req.params.id,
    { status: 'suspended' },
    { new: true }
  );

  if (!commerce) {
    return res.status(404).json({ success: false, message: 'Commerce not found' });
  }

  res.json({
    success: true,
    message: 'Commerce suspended',
    data: { commerce },
  });
});

exports.deleteCommerce = asyncHandler(async (req, res) => {
  const commerce = await Commerce.findById(req.params.id);

  if (!commerce) {
    return res.status(404).json({ success: false, message: 'Commerce not found' });
  }

  await Promise.all([
    Client.deleteMany({ commerce: commerce._id }),
    QRCode.deleteOne({ commerce: commerce._id }),
    ScanHistory.deleteMany({ commerce: commerce._id }),
    SupportRequest.deleteMany({ commerce: commerce._id }),
    Incident.deleteMany({ commerce: commerce._id }),
    User.findByIdAndUpdate(commerce.merchant, { $unset: { commerce: 1 } }),
    Commerce.findByIdAndDelete(commerce._id),
  ]);

  res.json({
    success: true,
    message: 'Commerce and related data deleted',
  });
});

// ─── Gérer support ─────────────────────────────────────────────────

exports.listSupportRequests = asyncHandler(async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;
  const filter = {};
  if (status) filter.status = status;

  const skip = (Number(page) - 1) * Number(limit);
  const [requests, total] = await Promise.all([
    SupportRequest.find(filter)
      .populate('submittedBy', 'firstName lastName email role')
      .populate('commerce', 'name')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit)),
    SupportRequest.countDocuments(filter),
  ]);

  res.json({
    success: true,
    data: { requests, pagination: { total, page: Number(page), limit: Number(limit) } },
  });
});

exports.getSupportRequest = asyncHandler(async (req, res) => {
  const request = await SupportRequest.findById(req.params.id)
    .populate('submittedBy', 'firstName lastName email role')
    .populate('commerce', 'name category')
    .populate('responses.author', 'firstName lastName role');

  if (!request) {
    return res.status(404).json({ success: false, message: 'Support request not found' });
  }

  res.json({ success: true, data: { request } });
});

exports.respondToSupport = asyncHandler(async (req, res) => {
  const { message } = req.body;
  const request = await SupportRequest.findById(req.params.id);

  if (!request) {
    return res.status(404).json({ success: false, message: 'Support request not found' });
  }

  if (request.status === 'closed') {
    return res.status(400).json({ success: false, message: 'Request is already closed' });
  }

  request.responses.push({
    message,
    author: req.user._id,
    authorRole: 'admin',
  });
  request.status = 'in_progress';
  await request.save();

  const updated = await SupportRequest.findById(request._id)
    .populate('responses.author', 'firstName lastName role');

  res.json({
    success: true,
    message: 'Response added',
    data: { request: updated },
  });
});

exports.closeSupportRequest = asyncHandler(async (req, res) => {
  const request = await SupportRequest.findById(req.params.id);

  if (!request) {
    return res.status(404).json({ success: false, message: 'Support request not found' });
  }

  request.status = 'closed';
  request.closedAt = new Date();
  request.closedBy = req.user._id;
  await request.save();

  res.json({
    success: true,
    message: 'Support request closed',
    data: { request },
  });
});

// ─── Gérer les incidents ───────────────────────────────────────────

exports.listIncidents = asyncHandler(async (req, res) => {
  const { status, type, page = 1, limit = 20 } = req.query;
  const filter = {};
  if (status) filter.status = status;
  if (type) filter.type = type;

  const skip = (Number(page) - 1) * Number(limit);
  const [incidents, total] = await Promise.all([
    Incident.find(filter)
      .populate('reportedBy', 'firstName lastName email role')
      .populate('commerce', 'name')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit)),
    Incident.countDocuments(filter),
  ]);

  res.json({
    success: true,
    data: { incidents, pagination: { total, page: Number(page), limit: Number(limit) } },
  });
});

exports.getIncident = asyncHandler(async (req, res) => {
  const incident = await Incident.findById(req.params.id)
    .populate('reportedBy', 'firstName lastName email role')
    .populate('commerce', 'name category')
    .populate('adminResponses.author', 'firstName lastName');

  if (!incident) {
    return res.status(404).json({ success: false, message: 'Incident not found' });
  }

  res.json({ success: true, data: { incident } });
});

exports.updateIncidentStatus = asyncHandler(async (req, res) => {
  const { status } = req.body;
  const incident = await Incident.findById(req.params.id);

  if (!incident) {
    return res.status(404).json({ success: false, message: 'Incident not found' });
  }

  incident.status = status;
  if (status === 'resolved' || status === 'dismissed') {
    incident.resolvedAt = new Date();
  }
  await incident.save();

  res.json({
    success: true,
    message: 'Incident status updated',
    data: { incident },
  });
});

exports.respondToIncident = asyncHandler(async (req, res) => {
  const { message } = req.body;
  const incident = await Incident.findById(req.params.id);

  if (!incident) {
    return res.status(404).json({ success: false, message: 'Incident not found' });
  }

  incident.adminResponses.push({
    message,
    author: req.user._id,
  });

  if (incident.status === 'reported') {
    incident.status = 'investigating';
  }

  await incident.save();

  const updated = await Incident.findById(incident._id)
    .populate('adminResponses.author', 'firstName lastName');

  res.json({
    success: true,
    message: 'Response added to incident',
    data: { incident: updated },
  });
});

exports.getGlobalStatistics = asyncHandler(async (req, res) => {
  const [
    totalCommerces,
    activeCommerces,
    suspendedCommerces,
    pendingCommerces,
    totalClients,
    totalMerchants,
    totalScans,
    totalTransactions,
    commercesByCategory,
    openSupport,
    openIncidents,
  ] = await Promise.all([
    Commerce.countDocuments(),
    Commerce.countDocuments({ status: 'active' }),
    Commerce.countDocuments({ status: 'suspended' }),
    Commerce.countDocuments({ status: 'pending' }),
    Client.countDocuments(),
    User.countDocuments({ role: 'merchant' }),
    ScanHistory.countDocuments(),
    LoyaltyTransaction.countDocuments(),
    Commerce.aggregate([
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
    ]),
    SupportRequest.countDocuments({ status: { $ne: 'closed' } }),
    Incident.countDocuments({ status: { $in: ['reported', 'investigating'] } }),
  ]);

  res.json({
    success: true,
    data: {
      commerces: {
        total: totalCommerces,
        active: activeCommerces,
        suspended: suspendedCommerces,
        pending: pendingCommerces,
        byCategory: commercesByCategory,
      },
      users: {
        merchants: totalMerchants,
        clients: totalClients,
      },
      activity: {
        totalQrScans: totalScans,
        totalLoyaltyTransactions: totalTransactions,
        openSupportRequests: openSupport,
        openIncidents,
      },
    },
  });
});

exports.listClients = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 50;
  const skip = (page - 1) * limit;

  const Client = require('../models/Client');

  const total = await Client.countDocuments();
  const clients = await Client.find()
    .sort('-createdAt')
    .skip(skip)
    .limit(limit)
    .populate('user', 'firstName lastName email phone isActive');

  res.json({
    success: true,
    count: clients.length,
    total,
    page,
    pages: Math.ceil(total / limit),
    data: { clients },
  });
});
