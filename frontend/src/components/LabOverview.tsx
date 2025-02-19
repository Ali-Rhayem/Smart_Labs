import React from 'react';
import {
  Box,
  Card,
  Grid,
  Typography,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  LinearProgress,
} from '@mui/material';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
// import GroupIcon from '@mui/icons-material/Group';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import { Lab } from '../types/dashboard';

interface LabOverviewProps {
  lab: Lab;
  index: number;
}

const LabOverview: React.FC<LabOverviewProps> = ({ lab, index }) => {
  return (
    <Accordion 
      sx={{ 
        bgcolor: 'var(--color-card)',
        mb: 2,
        '&:before': { display: 'none' }
      }}
    >
      <AccordionSummary expandIcon={<ExpandMoreIcon sx={{ color: 'var(--color-text)' }} />}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, width: '100%' }}>
          <Typography variant="h6" sx={{ color: 'var(--color-text)', flexGrow: 1 }}>
            Lab Session {index + 1} - {lab.xaxis[0]}
          </Typography>
          <Box sx={{ display: 'flex', gap: 3 }}>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" sx={{ color: 'var(--color-text-secondary)' }}>Attendance</Typography>
              <Typography 
                sx={{ 
                  color: lab.total_attendance >= 70 ? 'success.main' : 
                         lab.total_attendance >= 50 ? 'warning.main' : 'error.main'
                }}
              >
                {lab.total_attendance}%
              </Typography>
            </Box>
            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" sx={{ color: 'var(--color-text-secondary)' }}>PPE</Typography>
              <Typography 
                sx={{ 
                  color: lab.total_ppe_compliance >= 70 ? 'success.main' : 
                         lab.total_ppe_compliance >= 50 ? 'warning.main' : 'error.main'
                }}
              >
                {lab.total_ppe_compliance}%
              </Typography>
            </Box>
          </Box>
        </Box>
      </AccordionSummary>
      <AccordionDetails>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card sx={{ p: 2, bgcolor: 'var(--color-background)' }}>
              <Typography variant="h6" sx={{ color: 'var(--color-text)', mb: 2 }}>
                PPE Compliance Details
              </Typography>
              {Object.entries(lab.ppe_compliance).map(([type, value]) => (
                <Box key={type} sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                    <Typography sx={{ color: 'var(--color-text)' }}>
                      {type.charAt(0).toUpperCase() + type.slice(1)}
                    </Typography>
                    <Typography sx={{ color: 'var(--color-text)' }}>{value}%</Typography>
                  </Box>
                  <LinearProgress 
                    variant="determinate" 
                    value={value}
                    sx={{
                      height: 8,
                      borderRadius: 4,
                      bgcolor: 'var(--color-card)',
                      '& .MuiLinearProgress-bar': {
                        bgcolor: value >= 70 ? 'success.main' : 
                                value >= 50 ? 'warning.main' : 'error.main'
                      }
                    }}
                  />
                </Box>
              ))}
            </Card>
          </Grid>
          <Grid item xs={12} md={6}>
            <Card sx={{ p: 2, bgcolor: 'var(--color-background)' }}>
              <Typography variant="h6" sx={{ color: 'var(--color-text)', mb: 2 }}>
                Student Statistics
              </Typography>
              {lab.people.map(student => (
                <Box key={student.id} sx={{ mb: 2 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <Typography sx={{ color: 'var(--color-text)', flexGrow: 1 }}>
                      {student.name}
                    </Typography>
                    <Typography 
                      sx={{ 
                        color: student.attendance_percentage >= 70 ? 'success.main' : 
                               student.attendance_percentage >= 50 ? 'warning.main' : 'error.main'
                      }}
                    >
                      {student.attendance_percentage}%
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', gap: 2 }}>
                    {Object.entries(student.ppe_compliance || {}).map(([type, value]) => (
                      <Typography 
                        key={type}
                        variant="caption" 
                        sx={{ 
                          color: 'var(--color-text-secondary)',
                          display: 'flex',
                          alignItems: 'center',
                          gap: 0.5
                        }}
                      >
                        <VerifiedUserIcon sx={{ fontSize: 16 }} />
                        {type}: {value}%
                      </Typography>
                    ))}
                  </Box>
                </Box>
              ))}
            </Card>
          </Grid>
        </Grid>
      </AccordionDetails>
    </Accordion>
  );
};

export default LabOverview;