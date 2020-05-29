import Vue from 'vue';
import VueDisableInterpolation from 'vue-disable-interpolation';
import registerCustomElement from '@sonicgarden/vue-custom-element-rails';

import SkywayContainer from './components/SkywayContainer';

Vue.use(VueDisableInterpolation);

registerCustomElement('skyway-container', SkywayContainer);
