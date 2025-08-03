export default ({ action }) => {
  // Collections that should trigger Hugo rebuild
  const triggerCollections = [
    'posts',
    'pages',
    'resources',
    'team_members',
    'services',
    'training_content',
    'case_studies'
  ];

  // Hook into item changes
  action('items.create', async ({ collection }) => {
    if (triggerCollections.includes(collection)) {
      await triggerHugoBuild(collection, 'create');
    }
  });

  action('items.update', async ({ collection }) => {
    if (triggerCollections.includes(collection)) {
      await triggerHugoBuild(collection, 'update');
    }
  });

  action('items.delete', async ({ collection }) => {
    if (triggerCollections.includes(collection)) {
      await triggerHugoBuild(collection, 'delete');
    }
  });

  // Also trigger on file uploads
  action('files.upload', async () => {
    await triggerHugoBuild('files', 'upload');
  });
};

async function triggerHugoBuild(collection, event) {
  try {
    // Call the Hugo builder webhook
    const response = await fetch('http://hugo-builder:9000/hooks/directus-webhook', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Webhook-Type': 'directus-rebuild'
      },
      body: JSON.stringify({
        collection,
        event,
        timestamp: new Date().toISOString()
      })
    });

    if (!response.ok) {
      console.error('Failed to trigger Hugo build:', response.statusText);
    } else {
      console.log(`Hugo build triggered for ${collection} ${event}`);
    }
  } catch (error) {
    console.error('Error triggering Hugo build:', error);
  }
}