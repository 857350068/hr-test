import { defineStore } from 'pinia'
import { login as loginApi, getUserInfo as getUserInfoApi } from '@/api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: JSON.parse(localStorage.getItem('userInfo') || '{}'),
    isLoggedIn: !!localStorage.getItem('token')
  }),

  getters: {
    isAdmin: (state) => state.userInfo.role === 'HR_ADMIN',
    userName: (state) => state.userInfo.name || '',
    userRole: (state) => state.userInfo.role || '',
    deptId: (state) => state.userInfo.deptId || null
  },

  actions: {
    async login(loginForm) {
      const res = await loginApi(loginForm)
      this.token = res.data.token
      this.userInfo = res.data.user
      this.isLoggedIn = true
      localStorage.setItem('token', this.token)
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
      return res
    },

    logout() {
      this.token = ''
      this.userInfo = {}
      this.isLoggedIn = false
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
    },

    async getUserInfo() {
      const res = await getUserInfoApi()
      this.userInfo = res.data
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
      return res
    }
  }
})
