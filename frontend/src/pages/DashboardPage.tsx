import React from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
} from '@mui/material';
import { useUser } from '../contexts/UserContext';
import { useDashboard } from '../hooks/useDashboard';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import SchoolIcon from '@mui/icons-material/School';
import GroupsIcon from '@mui/icons-material/Groups';
import AssignmentTurnedInIcon from '@mui/icons-material/AssignmentTurnedIn';

const DashboardPage: React.FC = () => {
  const { user: authUser } = useUser();
  const { data: dashboardData, isLoading } = useDashboard();

  if (isLoading || !dashboardData) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 3 }}>
        <CircularProgress />
      </Box>
    );
  }

  // Define Lab type
  type Lab = {
    xaxis: string[];
    total_attendance: number;
    total_ppe_compliance: number;
    people: {
      id: string;
      name: string;
      attendance_percentage: number;
      ppE_compliance: { [key: string]: number };
    }[];
  };

  // Filter out empty labs
  const validLabs: Lab[] = (dashboardData.labs as unknown as Lab[]).filter((lab: Lab) => Object.keys(lab).length > 0);

  // Prepare data for charts

  const trendsData = validLabs.map((lab: Lab) => ({
    date: lab.xaxis[0],
    attendance: lab.total_attendance,
    ppe_compliance: lab.total_ppe_compliance,
  })).reverse();

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ color: 'var(--color-text)' }}>
        Dashboard Overview
      </Typography>

      {/* Overview Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={4}>
          <Card sx={{ 
            p: 3, 
            bgcolor: 'var(--color-card)',
            display: 'flex',
            alignItems: 'center',
            gap: 2
          }}>
            <SchoolIcon sx={{ fontSize: 40, color: 'var(--color-primary)' }} />
            <Box>
              <Typography variant="h4" sx={{ color: 'var(--color-text)' }}>
                {dashboardData.total_students}
              </Typography>
              <Typography sx={{ color: 'var(--color-text-secondary)' }}>
                Total Students
              </Typography>
            </Box>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card sx={{ 
            p: 3, 
            bgcolor: 'var(--color-card)',
            display: 'flex',
            alignItems: 'center',
            gap: 2
          }}>
            <GroupsIcon sx={{ fontSize: 40, color: 'var(--color-primary)' }} />
            <Box>
              <Typography variant="h4" sx={{ color: 'var(--color-text)' }}>
                {dashboardData.avg_attandance}%
              </Typography>
              <Typography sx={{ color: 'var(--color-text-secondary)' }}>
                Average Attendance
              </Typography>
            </Box>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card sx={{ 
            p: 3, 
            bgcolor: 'var(--color-card)',
            display: 'flex',
            alignItems: 'center',
            gap: 2
          }}>
            <AssignmentTurnedInIcon sx={{ fontSize: 40, color: 'var(--color-primary)' }} />
            <Box>
              <Typography variant="h4" sx={{ color: 'var(--color-text)' }}>
                {dashboardData.ppe_compliance}%
              </Typography>
              <Typography sx={{ color: 'var(--color-text-secondary)' }}>
                PPE Compliance
              </Typography>
            </Box>
          </Card>
        </Grid>
      </Grid>

      {/* Trends Chart */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12}>
          <Card sx={{ p: 3, bgcolor: 'var(--color-card)' }}>
            <Typography variant="h6" sx={{ mb: 2, color: 'var(--color-text)' }}>
              Performance Trends
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={trendsData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'var(--color-card)',
                    border: '1px solid var(--color-border)',
                    color: 'var(--color-text)'
                  }}
                />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="attendance" 
                  stroke="#8884d8" 
                  name="Attendance %"
                />
                <Line 
                  type="monotone" 
                  dataKey="ppe_compliance" 
                  stroke="#82ca9d" 
                  name="PPE Compliance %"
                />
              </LineChart>
            </ResponsiveContainer>
          </Card>
        </Grid>
      </Grid>

      {/* Students Table */}
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Card sx={{ p: 3, bgcolor: 'var(--color-card)' }}>
            <Typography variant="h6" sx={{ mb: 2, color: 'var(--color-text)' }}>
              Student Performance
            </Typography>
            <TableContainer component={Paper} sx={{ bgcolor: 'var(--color-card)' }}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell sx={{ color: 'var(--color-text)' }}>Student</TableCell>
                    <TableCell sx={{ color: 'var(--color-text)' }}>Attendance</TableCell>
                    <TableCell sx={{ color: 'var(--color-text)' }}>Goggles</TableCell>
                    <TableCell sx={{ color: 'var(--color-text)' }}>Helmet</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {validLabs[0]?.people.map((student) => (
                    <TableRow key={student.id}>
                      <TableCell sx={{ color: 'var(--color-text)' }}>{student.name}</TableCell>
                      <TableCell sx={{ color: 'var(--color-text)' }}>{student.attendance_percentage}%</TableCell>
                      <TableCell sx={{ color: 'var(--color-text)' }}>{student.ppE_compliance.goggles}%</TableCell>
                      <TableCell sx={{ color: 'var(--color-text)' }}>{student.ppE_compliance.helmet}%</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardPage;