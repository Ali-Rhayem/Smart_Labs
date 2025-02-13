import React from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CircularProgress,
} from '@mui/material';
import { useUser } from '../contexts/UserContext';

const DashboardPage: React.FC = () => {
  const { user: authUser } = useUser();

  if (!authUser) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ color: 'var(--color-text)' }}>
        Dashboard
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6} lg={4}>
          <Card sx={{ p: 3, bgcolor: 'var(--color-card)' }}>
            <Typography variant="h6" sx={{ color: 'var(--color-text)' }}>
              Welcome, {authUser.role}
            </Typography>
            <Typography sx={{ color: 'var(--color-text-secondary)' }}>
              Role: {authUser.role}
            </Typography>
          </Card>
        </Grid>

        <Grid item xs={12} md={6} lg={4}>
          <Card sx={{ p: 3, bgcolor: 'var(--color-card)' }}>
            <Typography variant="h6" sx={{ color: 'var(--color-text)' }}>
              Quick Stats
            </Typography>
            <Typography sx={{ color: 'var(--color-text-secondary)' }}>
              Coming soon...
            </Typography>
          </Card>
        </Grid>

        <Grid item xs={12} md={6} lg={4}>
          <Card sx={{ p: 3, bgcolor: 'var(--color-card)' }}>
            <Typography variant="h6" sx={{ color: 'var(--color-text)' }}>
              Recent Activity
            </Typography>
            <Typography sx={{ color: 'var(--color-text-secondary)' }}>
              No recent activity
            </Typography>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardPage;