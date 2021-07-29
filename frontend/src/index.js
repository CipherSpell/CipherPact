import React from 'react';
import ReactDOM from 'react-dom';
import { Route, BrowserRouter as Router, Switch } from 'react-router-dom';

import Landing from './components/Landing';

const routing = (
  <Router>
      <Switch>
          <Route exact path="/" component={ Landing } />
      </Switch>
  </Router>
);

ReactDOM.render(routing, document.getElementById('root'));
