import { AdminDashboardPage } from '@/pages/AdminDashboardPage';
import { LandingPage } from '@/pages/LandingPage';

const ADMIN_PATH = '/admin-dashboard';

function App() {
  if (window.location.pathname.replace(/\/+$/, '') === ADMIN_PATH) {
    return <AdminDashboardPage />;
  }
  return <LandingPage />;
}

export default App;
